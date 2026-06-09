import Foundation

struct CalendarDisplaySettings: Codable, Sendable {
    var showLunarCalendar: Bool
    var showSolarTerms: Bool
    var weekStartDay: WeekStartDay

    static let `default` = CalendarDisplaySettings(
        showLunarCalendar: true,
        showSolarTerms: true,
        weekStartDay: .sunday
    )
}
