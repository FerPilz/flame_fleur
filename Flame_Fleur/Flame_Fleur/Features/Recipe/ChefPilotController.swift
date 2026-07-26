import Foundation
@preconcurrency import AVFoundation
@preconcurrency import Speech
import Combine
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class ChefPilotController: NSObject, ObservableObject {
    enum State: Equatable {
        case idle
        case announcing
        case listening
        case speaking
    }

    struct PresentedAlert: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let message: String
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var currentStepIndex: Int?
    @Published var presentedAlert: PresentedAlert?

    private let synthesizer = AVSpeechSynthesizer()
    private let audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()
    private let speechRecognizer = SFSpeechRecognizer(locale: .autoupdatingCurrent)

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var stepInstructions: [String] = []
    private var observerTokens: [NSObjectProtocol] = []
    private var activeUtteranceKind: UtteranceKind?
    private var installedTapBus: AVAudioNodeBus?

    override init() {
        super.init()
        synthesizer.delegate = self
        speechRecognizer?.delegate = self
        observeInterruptions()
    }

    deinit {
        observerTokens.forEach(NotificationCenter.default.removeObserver)
    }

    func updateSteps(_ steps: [String]) {
        stepInstructions = steps

        if stepInstructions.isEmpty {
            deactivate(resetStepIndex: true)
        } else if let currentStepIndex, currentStepIndex >= stepInstructions.count {
            self.currentStepIndex = stepInstructions.indices.last
        }
    }

    func toggle() {
        if state == .idle {
            Task { [weak self] in
                await self?.activate()
            }
        } else {
            deactivate(resetStepIndex: true)
        }
    }

    func deactivate(resetStepIndex: Bool = true) {
        stopSpeech()
        stopListening()
        state = .idle
        activeUtteranceKind = nil

        if resetStepIndex {
            currentStepIndex = nil
        }

        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            // Ignore teardown failures; idle state is authoritative for UI.
        }
    }

    private func activate() async {
        guard !stepInstructions.isEmpty else {
            presentedAlert = PresentedAlert(
                title: "Chef Pilot unavailable",
                message: "This recipe needs at least one step before Chef Pilot can read it aloud."
            )
            return
        }

        guard speechRecognizer != nil else {
            presentedAlert = PresentedAlert(
                title: "Speech recognition unavailable",
                message: "Chef Pilot is not available for the current language settings on this device."
            )
            return
        }

        let permissionResult = await requestPermissions()
        guard permissionResult == .granted else {
            if case let .denied(message) = permissionResult {
                presentedAlert = PresentedAlert(title: "Chef Pilot needs access", message: message)
            }
            deactivate(resetStepIndex: true)
            return
        }

        beginAnnouncement()
    }

    private func beginAnnouncement() {
        do {
            try configureAudioSession()
            stopListening()
            let text = "Chef Pilot is ready. Say start to begin, stop to end, repeat to hear the current step again, or next to move to the next step."
            speak(text, kind: .announcement)
        } catch {
            presentedAlert = PresentedAlert(
                title: "Chef Pilot unavailable",
                message: "Chef Pilot could not start audio input right now. Please try again."
            )
            deactivate(resetStepIndex: true)
        }
    }

    private func configureAudioSession() throws {
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .defaultToSpeaker, .allowBluetoothHFP])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func speak(_ text: String, kind: UtteranceKind) {
        guard !text.isEmpty else { return }

        stopSpeech()
        activeUtteranceKind = kind
        state = kind == .announcement ? .announcing : .speaking

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.autoupdatingCurrent.language.languageCode?.identifier)
            ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.92
        utterance.pitchMultiplier = 1.0
        utterance.postUtteranceDelay = 0.08

        synthesizer.speak(utterance)
    }

    private func stopSpeech() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    private func startListening() throws {
        guard state != .idle else { return }
        guard let speechRecognizer else {
            throw ChefPilotError.recognizerUnavailable
        }

        stopListening()

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if speechRecognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            guard let self, let recognitionRequest = self.recognitionRequest else { return }
            recognitionRequest.append(buffer)
        }
        installedTapBus = 0

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            Task { @MainActor in
                if let error {
                    self.handleRecognitionFailure(error)
                    return
                }

                guard let result else { return }
                self.handleRecognitionResult(result)
            }
        }

        state = .listening
    }

    private func stopListening() {
        recognitionTask?.cancel()
        recognitionTask = nil

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        if audioEngine.isRunning {
            audioEngine.stop()
        }

        if installedTapBus != nil {
            audioEngine.inputNode.removeTap(onBus: 0)
            installedTapBus = nil
        }
    }

    private func restartListening() {
        guard state != .idle else { return }

        do {
            try configureAudioSession()
            try startListening()
        } catch {
            presentedAlert = PresentedAlert(
                title: "Chef Pilot stopped",
                message: "Chef Pilot could not continue listening for voice commands."
            )
            deactivate(resetStepIndex: true)
        }
    }

    private func handleRecognitionResult(_ result: SFSpeechRecognitionResult) {
        let transcript = result.bestTranscription.formattedString

        if state == .speaking {
            processInterruptCommandIfNeeded(in: transcript)
            return
        }

        guard state == .listening, !synthesizer.isSpeaking else {
            return
        }

        processCommand(in: transcript)
    }

    private func processCommand(in transcript: String) {
        let lowercasedTranscript = transcript.lowercased()

        if lowercasedTranscript.contains("stop") {
            deactivate(resetStepIndex: true)
            return
        }

        if lowercasedTranscript.contains("repeat") {
            repeatCurrentStep()
            return
        }

        if lowercasedTranscript.contains("next") {
            advanceToNextStep()
            return
        }

        if lowercasedTranscript.contains("start") {
            startCurrentStep()
        }
    }

    private func processInterruptCommandIfNeeded(in transcript: String) {
        let lowercasedTranscript = transcript.lowercased()
        let keywordMatches = ["stop", "repeat", "next"].filter { lowercasedTranscript.contains($0) }

        guard keywordMatches.count == 1 else {
            return
        }

        let wordCount = transcript.split(whereSeparator: \.isWhitespace).count
        guard wordCount <= 4 else {
            return
        }

        processCommand(in: transcript)
    }

    private func startCurrentStep() {
        guard !stepInstructions.isEmpty else { return }

        let stepIndex = currentStepIndex ?? 0
        currentStepIndex = stepIndex
        speakStep(at: stepIndex)
    }

    private func repeatCurrentStep() {
        guard let currentStepIndex else {
            return
        }

        speakStep(at: currentStepIndex)
    }

    private func advanceToNextStep() {
        guard let currentStepIndex else {
            startCurrentStep()
            return
        }

        let nextStepIndex = currentStepIndex + 1
        guard stepInstructions.indices.contains(nextStepIndex) else {
            speak("That was the last step.", kind: .completion)
            return
        }

        self.currentStepIndex = nextStepIndex
        speakStep(at: nextStepIndex)
    }

    private func speakStep(at index: Int) {
        guard stepInstructions.indices.contains(index) else {
            deactivate(resetStepIndex: true)
            return
        }

        currentStepIndex = index
        let instruction = stepInstructions[index].trimmingCharacters(in: .whitespacesAndNewlines)
        let spokenStep = "Step \(index + 1). \(instruction)"
        speak(spokenStep, kind: .step(index: index))
    }

    private func handleRecognitionFailure(_ error: Error) {
        guard state != .idle else { return }

        presentedAlert = PresentedAlert(
            title: "Chef Pilot stopped",
            message: "Voice control ended because speech recognition became unavailable."
        )
        deactivate(resetStepIndex: true)
    }

    private func handleUtteranceFinished(_ kind: UtteranceKind) {
        activeUtteranceKind = nil

        switch kind {
        case .announcement:
            restartListening()
        case let .step(index):
            if index == stepInstructions.indices.last {
                deactivate(resetStepIndex: true)
            } else {
                restartListening()
            }
        case .completion:
            deactivate(resetStepIndex: true)
        }
    }

    private func requestPermissions() async -> PermissionResult {
        let speechPermission = await requestSpeechPermission()
        guard speechPermission else {
            return .denied(message: "Allow Speech Recognition in Settings to let Chef Pilot understand hands-free commands.")
        }

        let microphonePermission = await requestMicrophonePermission()
        guard microphonePermission else {
            return .denied(message: "Allow Microphone access in Settings so Chef Pilot can listen for cooking commands.")
        }

        return .granted
    }

    private func requestSpeechPermission() async -> Bool {
        let currentStatus = SFSpeechRecognizer.authorizationStatus()
        switch currentStatus {
        case .authorized:
            return true
        case .denied, .restricted:
            return false
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: status == .authorized)
                }
            }
        @unknown default:
            return false
        }
    }

    private func requestMicrophonePermission() async -> Bool {
        if #available(iOS 17.0, *) {
            switch AVAudioApplication.shared.recordPermission {
            case .granted:
                return true
            case .denied:
                return false
            case .undetermined:
                return await withCheckedContinuation { continuation in
                    AVAudioApplication.requestRecordPermission { granted in
                        continuation.resume(returning: granted)
                    }
                }
            @unknown default:
                return false
            }
        } else {
            switch audioSession.recordPermission {
            case .granted:
                return true
            case .denied:
                return false
            case .undetermined:
                return await withCheckedContinuation { continuation in
                    audioSession.requestRecordPermission { granted in
                        continuation.resume(returning: granted)
                    }
                }
            @unknown default:
                return false
            }
        }
    }

    private func observeInterruptions() {
        let center = NotificationCenter.default

        observerTokens.append(
            center.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.deactivate(resetStepIndex: true)
                }
            }
        )

        #if canImport(UIKit)
        observerTokens.append(
            center.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.deactivate(resetStepIndex: true)
                }
            }
        )
        #endif
    }
}

private extension ChefPilotController {
    enum PermissionResult: Equatable {
        case granted
        case denied(message: String)
    }

    enum UtteranceKind: Equatable {
        case announcement
        case step(index: Int)
        case completion
    }

    enum ChefPilotError: LocalizedError {
        case recognizerUnavailable

        var errorDescription: String? {
            switch self {
            case .recognizerUnavailable:
                return "Speech recognition is unavailable."
            }
        }
    }
}

extension ChefPilotController: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            guard let self, let activeUtteranceKind else { return }
            handleUtteranceFinished(activeUtteranceKind)
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            self?.activeUtteranceKind = nil
        }
    }
}

extension ChefPilotController: SFSpeechRecognizerDelegate {
    nonisolated func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        guard !available else { return }

        Task { @MainActor [weak self] in
            guard let self, self.state != .idle else { return }
            self.presentedAlert = PresentedAlert(
                title: "Chef Pilot stopped",
                message: "Speech recognition is temporarily unavailable."
            )
            self.deactivate(resetStepIndex: true)
        }
    }
}
