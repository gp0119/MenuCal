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
                Toggle("显示节假日", isOn: $store.calendar.showPublicHolidays)
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

            Section("颜色") {
                CalendarColorPickerRow(
                    title: "今日颜色",
                    defaultColor: .defaultAccent,
                    selection: calendarColorBinding(
                        \.accentColor,
                        fallback: .defaultAccent
                    )
                )
                CalendarColorPickerRow(
                    title: "休息日",
                    defaultColor: .defaultHoliday,
                    selection: calendarColorBinding(
                        \.holidayColor,
                        fallback: .defaultHoliday
                    )
                )
                CalendarColorPickerRow(
                    title: "调休上班",
                    defaultColor: .defaultWorkday,
                    selection: calendarColorBinding(
                        \.workdayColor,
                        fallback: .defaultWorkday
                    )
                )
                CalendarColorPickerRow(
                    title: "节日",
                    defaultColor: .defaultFestival,
                    selection: calendarColorBinding(
                        \.festivalColor,
                        fallback: .defaultFestival
                    )
                )
                CalendarColorPickerRow(
                    title: "节气",
                    defaultColor: .defaultSolarTerm,
                    selection: calendarColorBinding(
                        \.solarTermColor,
                        fallback: .defaultSolarTerm
                    )
                )
            }
        }
        .formStyle(.grouped)
    }

    private func calendarColorBinding(
        _ keyPath: WritableKeyPath<CalendarDisplaySettings, CalendarColor?>,
        fallback: CalendarColor
    ) -> Binding<CalendarColor> {
        Binding(
            get: {
                store.calendar[keyPath: keyPath] ?? fallback
            },
            set: { color in
                var settings = store.calendar
                settings[keyPath: keyPath] = color
                store.calendar = settings
            }
        )
    }
}

private struct CalendarColorPickerRow: View {
    let title: String
    let defaultColor: CalendarColor
    @Binding var selection: CalendarColor

    var body: some View {
        HStack {
            Text(title)

            Spacer()

            HStack(spacing: 9) {
                ColorPicker(
                    "选择任意颜色",
                    selection: customColorBinding,
                    supportsOpacity: false
                )
                .labelsHidden()
                .controlSize(.mini)

                Button {
                    selection = defaultColor
                } label: {
                    Circle()
                        .fill(defaultColor.color)
                        .overlay {
                            Circle()
                                .stroke(.black.opacity(0.18), lineWidth: 1)
                        }
                        .overlay {
                            if isUsingDefaultColor {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .frame(width: 14, height: 14)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .help("恢复默认颜色")
            }
        }
    }

    private var customColorBinding: Binding<Color> {
        Binding(
            get: { selection.color },
            set: { color in
                guard let color = CalendarColor(color) else { return }
                selection = color
            }
        )
    }

    private var isUsingDefaultColor: Bool {
        let tolerance = 0.001
        return abs(selection.red - defaultColor.red) < tolerance
            && abs(selection.green - defaultColor.green) < tolerance
            && abs(selection.blue - defaultColor.blue) < tolerance
    }
}
