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
    let selectedDayID: String
    let onSelectDay: (CalendarDay) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(week.days) { day in
                DayCellView(
                    day: day,
                    focusedMonthID: focusedMonthID,
                    showLunarCalendar: showLunarCalendar,
                    showSolarTerms: showSolarTerms,
                    showPublicHolidays: showPublicHolidays,
                    isSelected: day.id == selectedDayID,
                    onSelect: onSelectDay
                )
            }
        }
        .frame(maxWidth: .infinity)
        // Fixed row height keeps every scroll item uniform, so programmatic
        // scrollTo lands precisely without estimating variable month heights.
        .frame(height: CalendarGridLayout.dayCellHeight)
    }
}
