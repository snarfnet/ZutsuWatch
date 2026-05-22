import Foundation
import SwiftData

// 気圧リスクレベル
enum HeadacheRisk: String, Codable {
    case low, medium, high

    var label: String {
        switch self {
        case .low: "低い"
        case .medium: "やや注意"
        case .high: "注意"
        }
    }

    var emoji: String {
        switch self {
        case .low: "😊"
        case .medium: "😐"
        case .high: "😣"
        }
    }
}

// 気圧記録ポイント
struct PressurePoint: Identifiable, Codable {
    let id: UUID
    let date: Date
    let pressure: Double // hPa

    init(date: Date, pressure: Double) {
        self.id = UUID()
        self.date = date
        self.pressure = pressure
    }
}

// 頭痛ダイアリーエントリ
@Model
final class HeadacheEntry {
    var date: Date
    var severity: Int // 1-3 (軽い, 普通, ひどい)
    var pressure: Double
    var note: String
    var tookMedicine: Bool

    init(date: Date = .now, severity: Int = 2, pressure: Double = 0, note: String = "", tookMedicine: Bool = false) {
        self.date = date
        self.severity = severity
        self.pressure = pressure
        self.note = note
        self.tookMedicine = tookMedicine
    }

    var severityEmoji: String {
        switch severity {
        case 1: "😕"
        case 2: "😖"
        default: "🤯"
        }
    }

    var severityLabel: String {
        switch severity {
        case 1: "軽い"
        case 2: "普通"
        default: "ひどい"
        }
    }
}
