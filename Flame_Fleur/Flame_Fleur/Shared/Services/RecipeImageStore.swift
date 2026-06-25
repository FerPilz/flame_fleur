import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

final class RecipeImageStore {
    static let shared = RecipeImageStore()

    private let fileManager: FileManager
    private let directoryURL: URL

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.directoryURL = RecipeImageStore.defaultDirectoryURL(fileManager: fileManager)
    }

    func saveImageData(_ data: Data) -> String? {
        #if canImport(UIKit)
        guard let image = UIImage(data: data), let pngData = image.pngData() else {
            return nil
        }
        let imageData = pngData
        #elseif canImport(AppKit)
        guard let image = NSImage(data: data), let tiffData = image.tiffRepresentation else {
            return nil
        }
        let imageData = tiffData
        #else
        let imageData = data
        #endif

        let fileName = "user_recipe_image_\(UUID().uuidString.lowercased()).png"
        let url = directoryURL.appendingPathComponent(fileName)

        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            try imageData.write(to: url, options: [.atomic])
            return fileName
        } catch {
            print("RecipeImageStore: failed to persist image: \(error)")
            return nil
        }
    }

    #if canImport(UIKit)
    func hasLocalImage(named imageName: String) -> Bool {
        fileManager.fileExists(atPath: directoryURL.appendingPathComponent(imageName).path)
    }

    func platformImage(named imageName: String) -> UIImage? {
        image(named: imageName)
    }

    func image(named imageName: String) -> UIImage? {
        let url = directoryURL.appendingPathComponent(imageName)
        return UIImage(contentsOfFile: url.path)
    }
    #elseif canImport(AppKit)
    func hasLocalImage(named imageName: String) -> Bool {
        fileManager.fileExists(atPath: directoryURL.appendingPathComponent(imageName).path)
    }

    func platformImage(named imageName: String) -> NSImage? {
        image(named: imageName)
    }

    func image(named imageName: String) -> NSImage? {
        let url = directoryURL.appendingPathComponent(imageName)
        return NSImage(contentsOfFile: url.path)
    }
    #endif

    private static func defaultDirectoryURL(fileManager: FileManager) -> URL {
        let baseDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        return baseDirectory
            .appendingPathComponent("Flame_Fleur", isDirectory: true)
            .appendingPathComponent("RecipeImages", isDirectory: true)
    }
}
