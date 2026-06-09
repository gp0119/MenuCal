import Foundation

enum WeekStartDay: String, CaseIterable, Codable, Identifiable, Sendable {
    case sunday
    case monday

    var id: Self { self }

    var displayName: String {
        switch self {
        case .sunday: "星期日"
        case .monday: "星期一"
        }
    }

    var firstWeekday: Int {
        switch self {
        case .sunday: 1
        case .monday: 2
        }
    }

    var weekdaySymbols: [String] {
        switch self {
        case .sunday: ["日", "一", "二", "三", "四", "五", "六"]
        case .monday: ["一", "二", "三", "四", "五", "六", "日"]
        }
    }
}
