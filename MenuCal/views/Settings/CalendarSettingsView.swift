//
//  CalendarSettingsView.swift
//  MenuCal
//
//  Created by gp on 2026/6/8.
//

import SwiftUI

struct CalendarSettingsView: View {
    @EnvironmentObject private var store: SettingsStore

    var body: some View {
        Form {
            Section("显示内容") {
                Toggle("显示农历", isOn: $store.calendar.showLunarCalendar)
                Toggle("显示节气", isOn: $store.calendar.showSolarTerms)
            }

            Section("每周开始于") {
                Picker("每周开始于", selection: $store.calendar.weekStartDay) {
                    ForEach(WeekStartDay.allCases) { day in
                        Text(day.displayName)
                            .tag(day)
                    }
                }
                .labelsHidden()
            }
        }
        .formStyle(.grouped)
    }
}
