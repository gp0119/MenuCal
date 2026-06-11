//
//  CalendarScrollView.swift
//  MenuCal
//
//  Created by gp on 2026/6/4.
//

import SwiftUI

struct CalendarScrollView: View {
    @Binding var scrollPosition: ScrollPosition
    let weeks: [CalendarWeek]
    let focusedMonthID: String?
    let showLunarCalendar: Bool
    let showSolarTerms: Bool
    let showPublicHolidays: Bool
    let showWeekNumbers: Bool
    let selectedDayID: String
    let accentColor: Color
    let holidayColor: Color
    let workdayColor: Color
    let festivalColor: Color
    let solarTermColor: Color
    let onSelectDay: (CalendarDay) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(weeks) { week in
                    WeekRowView(
                        week: week,
                        focusedMonthID: focusedMonthID,
                        showLunarCalendar: showLunarCalendar,
                        showSolarTerms: showSolarTerms,
                        showPublicHolidays: showPublicHolidays,
                        showWeekNumbers: showWeekNumbers,
                        selectedDayID: selectedDayID,
                        accentColor: accentColor,
                        holidayColor: holidayColor,
                        workdayColor: workdayColor,
                        festivalColor: festivalColor,
                        solarTermColor: solarTermColor,
                        onSelectDay: onSelectDay
                    )
                }
            }
            .padding(.trailing, CalendarGridLayout.trailingPadding)
            .scrollTargetLayout()
        }
        // Every row is one week of uniform height, so ScrollPosition tracks the
        // top-most week as the user scrolls and scrollTo(...) lands precisely on a
        // single call. The parent maps weeks to months for the header and jumps.
        .scrollPosition($scrollPosition, anchor: .top)
        .scrollBounceBehavior(.basedOnSize)
        .frame(height: CalendarGridLayout.gridHeight)
    }
}
