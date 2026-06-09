//
//  MenuCalApp.swift
//  MenuCal
//
//  Created by gp on 2026/6/3.
//

import Sparkle
import SwiftUI

@main
struct MenuCalApp: App {
    @StateObject private var settingsStore = SettingsStore()
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
                updater: updaterController.updater
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
