import SwiftUI

// MARK: - HomeView
struct HomeView: View {
    @EnvironmentObject var store: GratitudeStore
    @EnvironmentObject var languageManager: LanguageManager

    @State private var texts: [String] = ["", "", ""]
    @State private var showingSavedToast = false
    private var today = Date()

    private func load() {
        let entry = store.entry(for: today)
        texts = entry.lines + Array(repeating: "", count: max(0, 3 - entry.lines.count))
        if texts.count > 3 { texts = Array(texts.prefix(3)) }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text(languageManager.localized("today"))
                            .font(DesignSystem.Typography.largeTitle)
                            .foregroundColor(.primary)
                        
                        Text(formatted(date: today))
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text(languageManager.localized("three_thanks_note"))
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)

                    VStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(0..<3, id: \.self) { idx in
                            CardTextEditorIOS14(
                                text: Binding(get: { texts[idx] }, set: { texts[idx] = $0 }),
                                placeholder: languageManager.localized("thanks_input_placeholder_\(idx + 1)")
                            )
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)

                    Button(action: save) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .medium))
                            Text(languageManager.localized("save"))
                                .font(DesignSystem.Typography.callout)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                                .fill(Color.accentMapped(UserDefaults.standard.string(forKey: "kansha.accent") ?? "purple"))
                        )
                        .shadow(color: Color.accentMapped(UserDefaults.standard.string(forKey: "kansha.accent") ?? "purple").opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.lg)

                    Spacer(minLength: DesignSystem.Spacing.xxl)
                }
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: load)
            .toast(isPresented: $showingSavedToast, message: languageManager.localized("save"))
        }
    }

    private func save() {
        let trimmed = texts.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let entry = GratitudeEntry(lines: trimmed)
        store.set(entry, for: today)
        showingSavedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { showingSavedToast = false }
        UIApplication.hideKeyboard()
    }

    private func formatted(date: Date) -> String {
        let fmt = DateFormatter(); fmt.dateStyle = .medium; fmt.timeStyle = .none
        return fmt.string(from: date)
    }
}
