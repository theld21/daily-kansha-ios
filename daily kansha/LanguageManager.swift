import SwiftUI
import Foundation

// MARK: - LanguageManager
final class LanguageManager: ObservableObject {
    @Published private(set) var strings: [String: String] = [:]
    @Published private(set) var availableLanguages: [LanguageInfo] = []
    @AppStorage("kansha.language") var languageCode: String = "en" {
        didSet { loadLanguage(code: languageCode) }
    }

    struct LanguageInfo: Identifiable {
        let id: String
        let code: String
        let name: String
        let nativeName: String
    }

    init() { 
        loadAvailableLanguages()
        loadLanguage(code: languageCode) 
    }

    private func loadAvailableLanguages() {
        availableLanguages = [
            LanguageInfo(id: "en", code: "en", name: "English", nativeName: "English"),
            LanguageInfo(id: "vi", code: "vi", name: "Vietnamese", nativeName: "Tiếng Việt"),
            LanguageInfo(id: "ja", code: "ja", name: "Japanese", nativeName: "日本語")
        ]
    }

    func loadLanguage(code: String) {
        if let url = Bundle.main.url(forResource: code, withExtension: "json", subdirectory: "Languages"),
           let data = try? Data(contentsOf: url),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
            DispatchQueue.main.async { self.strings = dict }
        } else {
            DispatchQueue.main.async { 
                self.strings = ["error": "Language file not found"] 
            }
        }
    }

    func localized(_ key: String) -> String {
        strings[key] ?? key
    }
}
