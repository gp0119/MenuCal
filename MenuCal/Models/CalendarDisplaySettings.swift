import AppKit
import Foundation
import SwiftUI

struct CalendarColor: Codable, Equatable, Sendable {
    let red: Double
    let green: Double
    let blue: Double

    init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    init?(_ color: Color) {
        guard let color = NSColor(color).usingColorSpace(.sRGB) else { return nil }
        red = Double(color.redComponent)
        green = Double(color.greenComponent)
        blue = Double(color.blueComponent)
    }

    var color: Color {
        Color(red: red, green: green, blue: blue)
    }

    static let defaultAccent = CalendarColor(
        red: 0,
        green: 122.0 / 255.0,
        blue: 1
    )
    static let defaultHoliday = CalendarColor(
        red: 1,
        green: 56.0 / 255.0,
        blue: 60.0 / 255.0
    )
    static let defaultWorkday = CalendarColor(
        red: 1,
        green: 141.0 / 255.0,
        blue: 40.0 / 255.0
    )
    static let paletteBlue = CalendarColor(
        red: 47.0 / 255.0,
        green: 111.0 / 255.0,
        blue: 237.0 / 255.0
    )
    static let paletteRed = CalendarColor(
        red: 217.0 / 255.0,
        green: 79.0 / 255.0,
        blue: 79.0 / 255.0
    )
    static let paletteOrange = CalendarColor(
        red: 199.0 / 255.0,
        green: 122.0 / 255.0,
        blue: 25.0 / 255.0
    )
    static let paletteGreen = CalendarColor(
        red: 86.0 / 255.0,
        green: 177.0 / 255.0,
        blue: 67.0 / 255.0
    )
    static let defaultFestival = CalendarColor(
        red: 186.0 / 255.0,
        green: 93.0 / 255.0,
        blue: 57.0 / 255.0
    )
    static let defaultSolarTerm = CalendarColor(
        red: 33.0 / 255.0,
        green: 90.0 / 255.0,
        blue: 178.0 / 255.0
    )
}

struct CalendarDisplaySettings: Codable, Sendable {
    var showLunarCalendar: Bool
    var showSolarTerms: Bool
    var showPublicHolidays: Bool
    var weekStartDay: WeekStartDay
    var accentColor: CalendarColor?
    var holidayColor: CalendarColor?
    var workdayColor: CalendarColor?
    var festivalColor: CalendarColor?
    var solarTermColor: CalendarColor?

    static let `default` = CalendarDisplaySettings(
        showLunarCalendar: true,
        showSolarTerms: true,
        showPublicHolidays: true,
        weekStartDay: .sunday,
        accentColor: nil,
        holidayColor: nil,
        workdayColor: nil,
        festivalColor: nil,
        solarTermColor: nil
    )
}

extension CalendarDisplaySettings {
    private enum CodingKeys: String, CodingKey {
        case showLunarCalendar
        case showSolarTerms
        case showPublicHolidays
        case weekStartDay
        case accentColor
        case holidayColor
        case workdayColor
        case festivalColor
        case solarTermColor
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
        accentColor = try container.decodeIfPresent(
            CalendarColor.self,
            forKey: .accentColor
        )
        holidayColor = try container.decodeIfPresent(
            CalendarColor.self,
            forKey: .holidayColor
        )
        workdayColor = try container.decodeIfPresent(
            CalendarColor.self,
            forKey: .workdayColor
        )
        festivalColor = try container.decodeIfPresent(
            CalendarColor.self,
            forKey: .festivalColor
        )
        solarTermColor = try container.decodeIfPresent(
            CalendarColor.self,
            forKey: .solarTermColor
        )
    }
}
