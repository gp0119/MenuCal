//
//  MenuCalApp.swift
//  MenuCal
//
//  Created by gp on 2026/6/3.
//

import Sparkle
import SwiftUI
import Combine

private final class CalendarDayClock: ObservableObject {
    @Published private(set) var currentDate = Date.now

    private let calendar: Calendar
    private var cancellables: Set<AnyCancellable> = []

    init(calendar: Calendar = .current) {
        self.calendar = calendar

        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.update(to: date)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.update(to: .now)
            }
            .store(in: &cancellables)
    }

    private func update(to date: Date) {
        guard !calendar.isDate(date, inSameDayAs: currentDate) else { return }
        currentDate = date
    }
}

@main
struct MenuCalApp: App {
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var dayClock = CalendarDayClock()
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    var body: some Scene {
        MenuBarExtra {
            CalendarMenuView(
                weekStartDay: settingsStore.calendar.weekStartDay,
                updater: updaterController.updater,
                currentDate: dayClock.currentDate
            )
                .id(settingsStore.calendar.weekStartDay)
                .environmentObject(settingsStore)
        } label: {
            MenuBarLabelView()
                .environmentObject(settingsStore)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(settingsStore)
        }
    }
}
