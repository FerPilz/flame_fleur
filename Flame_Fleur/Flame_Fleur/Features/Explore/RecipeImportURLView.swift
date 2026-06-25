import SwiftUI

struct RecipeImportURLView: View {
    @Environment(\.dismiss) private var dismiss

    private let importService = RecipeImportService()

    @State private var urlText = ""
    @State private var statusMessage: String?
    @State private var isImporting = false
    @State private var parsedResult: RecipeImportResult?
    @State private var previewDraft: ImportedRecipeDraft?
    @State private var previewWarnings: [RecipeImportWarning] = []
    @State private var isPreviewPresented = false

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                header

                SurfaceCard(
                    backgroundColor: AppColors.elevatedCardBackground,
                    borderColor: AppColors.warmBorder,
                    cornerRadius: AppRadius.large,
                    contentPadding: AppSpacing.sm,
                    showsShadow: false
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Paste a recipe link and CookFlow will try to read the ingredients and instructions.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)

                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text("Recipe URL")
                                .font(AppTypography.bodyEmphasis)
                                .foregroundStyle(AppColors.primaryText)

                            TextField(
                                "",
                                text: $urlText,
                                prompt: Text("https://example.com/recipe").foregroundStyle(AppColors.tertiaryText)
                            )
                            .font(AppTypography.callout)
                            .foregroundStyle(AppColors.primaryText)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                            .padding(.horizontal, AppSpacing.sm)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                                    .fill(AppColors.appBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                                    .stroke(AppColors.warmBorder, lineWidth: 1)
                            )
                        }

                        if let statusMessage {
                            Text(statusMessage)
                                .font(AppTypography.metadata)
                                .foregroundStyle(AppColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if let parsedResult {
                            parsedSummaryView(for: parsedResult)
                        }

                        PrimaryButton(
                            isImporting ? "Importing..." : "Import Recipe",
                            systemImage: isImporting ? nil : "square.and.arrow.down",
                            style: .recipe
                        ) {
                            importTapped()
                        }
                        .disabled(isImporting || urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity((isImporting || urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.55 : 1)

                        if isImporting {
                            HStack(spacing: AppSpacing.xs) {
                                ProgressView()
                                    .tint(AppColors.olive)

                                Text("Downloading page HTML...")
                                    .font(AppTypography.metadata)
                                    .foregroundStyle(AppColors.secondaryText)
                            }
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.lg)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isPreviewPresented, onDismiss: {
            previewDraft = nil
            previewWarnings = []
        }) {
            if let previewDraft {
                RecipeImportPreviewView(draft: previewDraft, warnings: previewWarnings)
            }
        }
    }

    private var header: some View {
        ZStack {
            HStack {
                IconCircleButton(
                    systemName: "chevron.left",
                    accessibilityLabel: "Back",
                    size: AppTopActionMetrics.buttonSize,
                    action: { dismiss() }
                )

                Spacer()
            }

            Text("Import Recipe")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)
                .accessibilityAddTraits(.isHeader)
        }
        .frame(height: 44)
    }

    private func importTapped() {
        let trimmedURL = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty else {
            statusMessage = "Add a recipe link first."
            return
        }

        statusMessage = nil
        parsedResult = nil
        previewDraft = nil
        previewWarnings = []
        isPreviewPresented = false
        isImporting = true

        Task {
            let result = await importService.importRecipe(from: trimmedURL)
            await MainActor.run {
                isImporting = false
                parsedResult = result

                switch result {
                case .success(let draft):
                    statusMessage = "Parsed \(draft.title). Review the imported details below."
                    previewDraft = draft
                    previewWarnings = []
                    isPreviewPresented = true
                case .partial(let draft, let warnings):
                    statusMessage = "Parsed \(draft.title) with \(warnings.count) warning\(warnings.count == 1 ? "" : "s"). Review below."
                    previewDraft = draft
                    previewWarnings = warnings
                    isPreviewPresented = true
                case .failure(let error):
                    statusMessage = error.localizedDescription
                    parsedResult = nil
                }
            }
        }
    }

    @ViewBuilder
    private func parsedSummaryView(for result: RecipeImportResult) -> some View {
        switch result {
        case .success(let draft):
            parsedSummaryCard(draft: draft, warnings: [])
        case .partial(let draft, let warnings):
            parsedSummaryCard(draft: draft, warnings: warnings)
        case .failure:
            EmptyView()
        }
    }

    private func parsedSummaryCard(draft: ImportedRecipeDraft, warnings: [RecipeImportWarning]) -> some View {
        SurfaceCard(
            backgroundColor: AppColors.softOlive.opacity(0.14),
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm,
            showsShadow: false
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(alignment: .top, spacing: AppSpacing.sm) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.olive)

                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text(draft.title)
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(AppColors.primaryText)
                            .lineLimit(2)

                        Text(draft.sourceHost ?? draft.sourceURL.host ?? draft.sourceURL.absoluteString)
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }

                HStack(spacing: AppSpacing.md) {
                    summaryMetric(label: "Ingredients", value: "\(draft.ingredients.count)")
                    summaryMetric(label: "Steps", value: "\(draft.instructions.count)")
                    summaryMetric(label: "Servings", value: draft.servings.map(String.init) ?? "—")
                }

                if !warnings.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Warnings")
                            .font(AppTypography.bodyEmphasis)
                            .foregroundStyle(AppColors.primaryText)

                        ForEach(warnings, id: \.self) { warning in
                            Text(warning.displayText)
                                .font(AppTypography.metadata)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
                }
            }
        }
    }

    private func summaryMetric(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(label)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
            Text(value)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.primaryText)
        }
    }
}

#Preview {
    RecipeImportURLView()
}
