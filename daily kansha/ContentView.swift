import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    @AppStorage("kansha.darkMode") private var isDarkMode: Bool = false
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var store = GratitudeStore()

    var body: some View {
        MainTabView()
            .environmentObject(languageManager)
            .environmentObject(store)
            .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct MainTabView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @AppStorage("kansha.accent") private var accentChoice: String = "purple"
    @State private var selection = 1

    var accentColor: Color { Color.accentMapped(accentChoice) }

    var body: some View {
        TabView(selection: $selection) {
            CalendarView()
                .tabItem { 
                    VStack {
                        Image(systemName: selection == 0 ? "calendar.circle.fill" : "calendar.circle")
                            .font(.system(size: 20, weight: .medium))
                        Text(languageManager.localized("calendar"))
                            .font(DesignSystem.Typography.caption)
                    }
                }
                .tag(0)

            HomeView()
                .tabItem { 
                    VStack {
                        Image(systemName: selection == 1 ? "house.circle.fill" : "house.circle")
                            .font(.system(size: 20, weight: .medium))
                        Text(languageManager.localized("today"))
                            .font(DesignSystem.Typography.caption)
                    }
                }
                .tag(1)

            ProfileView()
                .tabItem { 
                    VStack {
                        Image(systemName: selection == 2 ? "person.circle.fill" : "person.circle")
                            .font(.system(size: 20, weight: .medium))
                        Text(languageManager.localized("profile"))
                            .font(DesignSystem.Typography.caption)
                    }
                }
                .tag(2)
        }
        .accentColor(accentColor)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

