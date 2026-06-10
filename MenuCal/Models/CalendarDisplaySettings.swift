import Foundation

struct CalendarDisplaySettings: Codable, Sendable {
    var showLunarCalendar: Bool
    var showSolarTerms: Bool
    var showPublicHolidays: Bool
    var weekStartDay: WeekStartDay

    static let `default` = CalendarDisplaySettings(
        showLunarCalendar: true,
        showSolarTerms: true,
        showPublicHolidays: true,
        weekStartDay: .sunday
    )
}

extension CalendarDisplaySettings {
    private enum CodingKeys: String, CodingKey {
        case showLunarCalendar
        case showSolarTerms
        case showPublicHolidays
        case weekStartDay
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        showLunarCalendar = try container.decode(Bool.self, forKey: .showLunarCalendar)
        showSolarTerms = try container.decode(Bool.self, forKey: .showSolarTerms)
        showPublicHolidays = try container.decodeIfPresent(
            Bool.self,
            forKey: .showPublicHolidays
        ) ?? true
        weekStartDay = try container.decode(WeekStartDay.self, forKey: .weekStartDay)
    }
}
