import SwiftUI
import Foundation

// MARK: - Model
struct GratitudeEntry: Codable {
    var lines: [String] = ["", "", ""]
}

final class GratitudeStore: ObservableObject {
    @Published private(set) var data: [String: GratitudeEntry] = [:]
    private let defaultsKey = "KanshaGratitudeStore.v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() { load() }

    private func dateKey(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.calendar = Calendar(identifier: .gregorian)
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }

    func entry(for date: Date) -> GratitudeEntry {
        let key = dateKey(from: date)
        return data[key] ?? GratitudeEntry()
    }

    func set(_ entry: GratitudeEntry, for date: Date) {
        let key = dateKey(from: date)
        data[key] = entry
        save()
    }

    func clearAll() {
        data.removeAll()
        UserDefaults.standard.removeObject(forKey: defaultsKey)
        save()
    }

    private func save() {
        do {
            let d = try encoder.encode(data)
            UserDefaults.standard.set(d, forKey: defaultsKey)
        } catch {
            print("Save error:", error)
        }
    }

    private func load() {
        guard let d = UserDefaults.standard.data(forKey: defaultsKey) else { return }
        do {
            let decoded = try decoder.decode([String: GratitudeEntry].self, from: d)
            data = decoded
        } catch {
            print("Load error:", error)
        }
    }
}
