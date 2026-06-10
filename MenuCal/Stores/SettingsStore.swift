//
//  SettingsStore.swift
//  MenuCal
//
//  Created by gp on 2026/6/8.
//

import Combine
import Foundation

@MainActor
final class SettingsStore: ObservableObject {
    @Published var menuBar: MenuBarDisplaySettings {
        didSet { persist(menuBar, forKey: Keys.menuBar) }
    }

    @Published var calendar: CalendarDisplaySettings {
        didSet { persist(calendar, forKey: Keys.calendar) }
    }

    @Published var uses24HourTime: Bool {
        didSet { defaults.set(uses24HourTime, forKey: Keys.uses24HourTime) }
    }

    @Published var showsAMPM: Bool {
        didSet { defaults.set(showsAMPM, forKey: Keys.showsAMPM) }
    }

    @Published var remembersLastDisplayedDate: Bool {
        didSet {
            defaults.set(
                remembersLastDisplayedDate,
                forKey: Keys.remembersLastDisplayedDate
            )
        }
    }

    @Published var showsWeekNumbers: Bool {
        didSet { defaults.set(showsWeekNumbers, forKey: Keys.showsWeekNumbers) }
    }

    private enum Keys {
        static let menuBar = "menuBarDisplaySettings"
        static let calendar = "calendarDisplaySettings"
        static let uses24HourTime = "uses24HourTime"
        static let showsAMPM = "showsAMPM"
        static let remembersLastDisplayedDate = "remembersLastDisplayedDate"
        static let showsWeekNumbers = "showsWeekNumbers"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        menuBar = Self.load(MenuBarDisplaySettings.self, forKey: Keys.menuBar, from: defaults)?
            .normalized() ?? .default
        calendar = Self.load(
            CalendarDisplaySettings.self,
            forKey: Keys.calendar,
            from: defaults
        ) ?? .default
        uses24HourTime = defaults.object(forKey: Keys.uses24HourTime) as? Bool ?? true
        showsAMPM = defaults.object(forKey: Keys.showsAMPM) as? Bool ?? true
        remembersLastDisplayedDate =
            defaults.object(forKey: Keys.remembersLastDisplayedDate) as? Bool ?? false
        showsWeekNumbers =
            defaults.object(forKey: Keys.showsWeekNumbers) as? Bool ?? false
    }

    private func persist<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load<T: Decodable>(_ type: T.Type, forKey key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
