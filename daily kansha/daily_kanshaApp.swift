import SwiftUI
import UserNotifications

@main
struct daily_kanshaApp: App {
    @StateObject private var store = GratitudeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        if settings.authorizationStatus == .notDetermined {
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
                        }
                    }
                }
        }
    }
}
