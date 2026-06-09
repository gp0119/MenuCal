//
//  MenuCalApp.swift
//  MenuCal
//
//  Created by gp on 2026/6/3.
//

import SwiftUI

@main
struct MenuCalApp: App {
    @StateObject private var settingsStore = SettingsStore()

    var body: some Scene {
        MenuBarExtra {
            CalendarMenuView(weekStartDay: settingsStore.calendar.weekStartDay)
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
