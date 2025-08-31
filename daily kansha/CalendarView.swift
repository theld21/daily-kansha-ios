import SwiftUI

// MARK: - CalendarView
struct CalendarView: View {
    @EnvironmentObject var store: GratitudeStore
    @EnvironmentObject var languageManager: LanguageManager

    @State private var selected = Date()
    @State private var editing: Bool = false
    @State private var draftTexts: [String] = ["", "", ""]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        DatePicker(languageManager.localized("calendar"), selection: $selected, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .fill(Color.cardBackground)
                            .shadow(color: DesignSystem.Shadow.light, radius: 4, x: 0, y: 2)
                    )
                    .padding(.horizontal, DesignSystem.Spacing.md)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text(formatted(date: selected))
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(.primary)
                                
                                Text(languageManager.localized("gratitude_practice"))
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: toggleEdit) {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: editing ? "checkmark.circle.fill" : "pencil.circle.fill")
                                        .font(.system(size: 16, weight: .medium))
                                    Text(editing ? languageManager.localized("done") : languageManager.localized("edit"))
                                        .font(DesignSystem.Typography.callout)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(Color.accentMapped(UserDefaults.standard.string(forKey: "kansha.accent") ?? "purple"))
                            }
                        }

                        VStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(0..<3, id: \.self) { idx in
                                if editing {
                                    ModernTextField(
                                        text: Binding(get: { draftTexts[idx] }, set: { draftTexts[idx] = $0 }),
                                        placeholder: "\(languageManager.localized("save")) \(idx+1)"
                                    )
                                } else {
                                    GratitudeEntryCard(
                                        index: idx,
                                        text: idx < store.entry(for: selected).lines.count ? store.entry(for: selected).lines[idx] : "",
                                        languageManager: languageManager
                                    )
                                }
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .fill(Color.cardBackground)
                            .shadow(color: DesignSystem.Shadow.light, radius: 4, x: 0, y: 2)
                    )
                    .padding(.horizontal, DesignSystem.Spacing.md)

                    Spacer(minLength: DesignSystem.Spacing.xxl)
                }
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
            .navigationBarTitle(languageManager.localized("calendar"), displayMode: .inline)
            .onAppear(perform: loadDraft)
        }
    }

    private func loadDraft() {
        let e = store.entry(for: selected)
        draftTexts = e.lines + Array(repeating: "", count: max(0, 3 - e.lines.count))
        if draftTexts.count > 3 { draftTexts = Array(draftTexts.prefix(3)) }
    }

    private func toggleEdit() {
        if editing {
            let trimmed = draftTexts.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            store.set(GratitudeEntry(lines: trimmed), for: selected)
            UIApplication.hideKeyboard()
        } else { loadDraft() }
        editing.toggle()
    }

    private func formatted(date: Date) -> String {
        let fmt = DateFormatter(); fmt.dateStyle = .full; return fmt.string(from: date)
    }
}
