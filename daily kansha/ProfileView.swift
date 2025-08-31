import SwiftUI
import UserNotifications

// MARK: - ProfileView
struct ProfileView: View {
    @EnvironmentObject var store: GratitudeStore
    @EnvironmentObject var languageManager: LanguageManager

    @AppStorage("kansha.username") private var username: String = ""
    @AppStorage("kansha.reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("kansha.reminderHour") private var reminderHour: Int = 21
    @AppStorage("kansha.reminderMinute") private var reminderMinute: Int = 0
    @AppStorage("kansha.darkMode") private var isDarkMode: Bool = false
    @AppStorage("kansha.language") private var languageCode: String = "en"
    @AppStorage("kansha.accent") private var accentChoice: String = "purple"

    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    ModernSection(title: languageManager.localized("profile"), icon: "person.circle.fill") {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            ModernTextField(text: $username, placeholder: languageManager.localized("name_optional"))
                        }
                    }

                    ModernSection(title: languageManager.localized("display"), icon: "paintbrush.fill") {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            HStack {
                                Label(isDarkMode ? languageManager.localized("dark_mode") : languageManager.localized("light_mode"), 
                                      systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .font(DesignSystem.Typography.body)
                                Spacer()
                                Toggle("", isOn: $isDarkMode)
                                    .toggleStyle(SwitchToggleStyle(tint: Color.accentMapped(accentChoice)))
                            }
                            .padding(DesignSystem.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                    .fill(Color.elevatedBackground)
                            )

                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text(languageManager.localized("accent_color"))
                                    .font(DesignSystem.Typography.callout)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: DesignSystem.Spacing.sm) {
                                    ForEach(["blue","green","orange","purple","red","gray","black"], id: \.self) { color in
                                        ColorPickerButton(
                                            color: color,
                                            isSelected: accentChoice == color
                                        ) {
                                            accentChoice = color
                                        }
                                    }
                                }
                            }
                            .padding(DesignSystem.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                    .fill(Color.elevatedBackground)
                            )

                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text(languageManager.localized("language"))
                                    .font(DesignSystem.Typography.callout)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                ForEach(languageManager.availableLanguages) { language in
                                    LanguagePickerRow(
                                        language: language,
                                        isSelected: languageCode == language.code
                                    ) {
                                        languageCode = language.code
                                        languageManager.loadLanguage(code: language.code)
                                    }
                                }
                            }
                            .padding(DesignSystem.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                    .fill(Color.elevatedBackground)
                            )
                        }
                    }

                    ModernSection(title: languageManager.localized("reminder"), icon: "bell.fill") {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            HStack {
                                Text(languageManager.localized("enable_evening_reminder"))
                                    .font(DesignSystem.Typography.body)
                                Spacer()
                                Toggle("", isOn: $reminderEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: Color.accentMapped(accentChoice)))
                                    .onChange(of: reminderEnabled) { on in 
                                        if on { scheduleReminder() } else { cancelReminder() } 
                                    }
                            }
                            .padding(DesignSystem.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                    .fill(Color.elevatedBackground)
                            )

                            if reminderEnabled {
                                HStack {
                                    Text(languageManager.localized("reminder_time"))
                                        .font(DesignSystem.Typography.body)
                                    Spacer()
                                    DatePicker("", selection: Binding(get: {
                                        var comp = DateComponents()
                                        comp.hour = reminderHour
                                        comp.minute = reminderMinute
                                        return Calendar.current.date(from: comp) ?? Date()
                                    }, set: { newDate in
                                        let comps = Calendar.current.dateComponents([.hour,.minute], from: newDate)
                                        reminderHour = comps.hour ?? 21
                                        reminderMinute = comps.minute ?? 0
                                        if reminderEnabled { scheduleReminder() }
                                    }), displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                }
                                .padding(DesignSystem.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                        .fill(Color.elevatedBackground)
                                )
                            }
                        }
                    }

                    ModernSection(title: languageManager.localized("about"), icon: "info.circle.fill") {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text(languageManager.localized("about_description"))
                                .font(DesignSystem.Typography.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                            
                            Text(languageManager.localized("version"))
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(DesignSystem.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .fill(Color.elevatedBackground)
                        )
                    }



                    Spacer(minLength: DesignSystem.Spacing.xxl)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
            .navigationBarTitle(languageManager.localized("profile"), displayMode: .inline)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(languageManager.localized("reset_confirm_title")), 
                    message: Text(languageManager.localized("reset_confirm_message")), 
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear { 
                languageManager.loadLanguage(code: languageCode) 
            }
        }
    }

    private func scheduleReminder() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = languageManager.localized("reminder_title")
            content.body = languageManager.localized("reminder_body")
            content.sound = .default
            var comps = DateComponents(); comps.hour = reminderHour; comps.minute = reminderMinute
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let req = UNNotificationRequest(identifier: "kansha.dailyReminder", content: content, trigger: trigger)
            center.add(req) { err in if let e = err { print("Schedule error:", e) } }
        }
    }

    private func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["kansha.dailyReminder"])
    }
}
