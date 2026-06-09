//
//  MenuBarLabelBuilder.swift
//  MenuCal
//
//  Created by gp on 2026/6/8.
//

import Foundation

struct MenuBarSegment: Identifiable {
    enum Kind {
        case icon(systemName: String)
        case calendarGlyph(text: String)
        case text(String)
    }

    let id: MenuBarComponent
    let kind: Kind
}

enum MenuBarLabelBuilder {
    static func segments(
        for settings: MenuBarDisplaySettings,
        date: Date,
        uses24HourTime: Bool,
        showsAMPM: Bool
    ) -> [MenuBarSegment] {
        settings.items
            .filter(\.isEnabled)
            .compactMap {
                segment(
                    for: $0.component,
                    date: date,
                    settings: settings,
                    uses24HourTime: uses24HourTime,
                    showsAMPM: showsAMPM
                )
            }
    }

    private static func segment(
        for component: MenuBarComponent,
        date: Date,
        settings: MenuBarDisplaySettings,
        uses24HourTime: Bool,
        showsAMPM: Bool
    ) -> MenuBarSegment? {
        let showSeconds = settings.showSeconds
        switch component {
        case .icon:
            return iconSegment(style: settings.iconStyle, date: date)
        case .year:
            return text(component, yearFormatter.string(from: date))
        case .lunarYear:
            return text(component, LunarDateFormatter.shared.lunarYear(for: date))
        case .lunarDay:
            return text(component, LunarDateFormatter.shared.lunarDay(for: date))
        case .date:
            return text(component, dateFormatter.string(from: date))
        case .weekday:
            return text(component, weekdayFormatter.string(from: date))
        case .time:
            let formatter: DateFormatter
            if uses24HourTime {
                formatter = showSeconds ? timeWithSecondsFormatter : timeFormatter
            } else if showsAMPM {
                formatter = showSeconds ? twelveHourTimeWithSecondsFormatter : twelveHourTimeFormatter
            } else {
                formatter = showSeconds
                    ? twelveHourTimeWithoutPeriodWithSecondsFormatter
                    : twelveHourTimeWithoutPeriodFormatter
            }
            return text(component, formatter.string(from: date))
        }
    }

    /// The text drawn inside the calendar glyph for a given icon style, or `nil`
    /// for the plain calendar symbol. Shared with the settings preview.
    static func iconGlyphText(for style: MenuBarIconStyle, date: Date) -> String? {
        switch style {
        case .calendar:
            return nil
        case .dayOfMonth:
            return dayFormatter.string(from: date)
        case .weekday:
            return narrowWeekdays[calendar.component(.weekday, from: date) - 1]
        }
    }

    private static func iconSegment(style: MenuBarIconStyle, date: Date) -> MenuBarSegment {
        guard let glyph = iconGlyphText(for: style, date: date) else {
            return MenuBarSegment(id: .icon, kind: .icon(systemName: "calendar"))
        }
        return MenuBarSegment(id: .icon, kind: .calendarGlyph(text: glyph))
    }

    private static func text(_ component: MenuBarComponent, _ value: String) -> MenuBarSegment? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        return MenuBarSegment(id: component, kind: .text(trimmed))
    }

    private static let locale = Locale(identifier: "zh_CN")
    private static let calendar = Calendar(identifier: .gregorian)
    private static let narrowWeekdays = ["日", "一", "二", "三", "四", "五", "六"]

    private static func formatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = format
        return formatter
    }

    private static let yearFormatter = formatter("yyyy年")
    private static let dayFormatter = formatter("d")
    private static let dateFormatter = formatter("M月d日")
    private static let weekdayFormatter = formatter("EEE")
    private static let timeFormatter = formatter("HH:mm")
    private static let timeWithSecondsFormatter = formatter("HH:mm:ss")
    private static let twelveHourTimeFormatter = formatter("a h:mm")
    private static let twelveHourTimeWithSecondsFormatter = formatter("a h:mm:ss")
    private static let twelveHourTimeWithoutPeriodFormatter = formatter("h:mm")
    private static let twelveHourTimeWithoutPeriodWithSecondsFormatter = formatter("h:mm:ss")
}
