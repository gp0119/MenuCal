//
//  WeekRowView.swift
//  MenuCal
//
//  Created by gp on 2026/6/4.
//

import SwiftUI

struct WeekRowView: View {
    let week: CalendarWeek
    let focusedMonthID: String?
    let showLunarCalendar: Bool
    let showSolarTerms: Bool
    let showPublicHolidays: Bool
    let showWeekNumbers: Bool
    let selectedDayID: String
    let currentDayID: String
    let accentColor: Color
    let holidayColor: Color
    let workdayColor: Color
    let festivalColor: Color
    let solarTermColor: Color
    let onSelectDay: (CalendarDay) -> Void

    var body: some View {
        HStack(spacing: 0) {
            if showWeekNumbers, let weekOfYear = week.days.first?.weekOfYear {
                Text("\(weekOfYear)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(width: CalendarGridLayout.weekNumberColumnWidth)
            }

            ForEach(week.days) { day in
                DayCellView(
                    day: day,
                    focusedMonthID: focusedMonthID,
                    showLunarCalendar: showLunarCalendar,
                    showSolarTerms: showSolarTerms,
                    showPublicHolidays: showPublicHolidays,
                    isSelected: day.id == selectedDayID,
                    isToday: day.id == currentDayID,
                    accentColor: accentColor,
                    holidayColor: holidayColor,
                    workdayColor: workdayColor,
                    festivalColor: festivalColor,
                    solarTermColor: solarTermColor,
                    onSelect: onSelectDay
                )
            }
        }
        .frame(maxWidth: .infinity)
        // Fixed row height keeps every scroll item uniform, so programmatic
        // scrollTo lands precisely without estimating variable month heights.
        .frame(height: CalendarGridLayout.dayCellSize)
    }
}
