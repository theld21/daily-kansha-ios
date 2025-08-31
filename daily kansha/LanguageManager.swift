import SwiftUI
import Foundation

// MARK: - LanguageManager (reads JSON files in bundle: en.json, vi.json, ja.json)
// 
// CÁCH THÊM NGÔN NGỮ MỚI:
// 1. Tạo file JSON mới (ví dụ: fr.json) trong thư mục "daily kansha/"
// 2. Thêm LanguageInfo vào availableLanguages array trong loadAvailableLanguages()
// 3. Thêm file JSON vào Xcode project (Add Files to Project)
// 4. Đảm bảo file được thêm vào target để app có thể đọc được
// 5. App sẽ tự động load file JSON, không cần fallback code
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
        // Để thêm ngôn ngữ mới, chỉ cần thêm vào array này
        // và tạo file JSON tương ứng trong bundle
        availableLanguages = [
            LanguageInfo(id: "en", code: "en", name: "English", nativeName: "English"),
            LanguageInfo(id: "vi", code: "vi", name: "Vietnamese", nativeName: "Tiếng Việt"),
            LanguageInfo(id: "ja", code: "ja", name: "Japanese", nativeName: "日本語")
        ]
    }

    func loadLanguage(code: String) {
        if let url = Bundle.main.url(forResource: code, withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
            DispatchQueue.main.async { self.strings = dict }
        } else {
            // Fallback về tiếng Anh nếu không tìm thấy file JSON
            DispatchQueue.main.async { 
                self.strings = ["error": "Language file not found"] 
            }
        }
    }

    func localized(_ key: String) -> String {
        strings[key] ?? key
    }
}
