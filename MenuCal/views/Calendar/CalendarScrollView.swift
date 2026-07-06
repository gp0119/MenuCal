//
//  CalendarScrollView.swift
//  MenuCal
//
//  Created by gp on 2026/6/4.
//

import SwiftUI

struct CalendarScrollRequest: Equatable {
    let weekID: String
    let token: Int
    let disablesAnimations: Bool
}

struct CalendarScrollView: View {
    @State private var scrollPosition: ScrollPosition

    let initialScrollWeekID: String?
    let scrollRequest: CalendarScrollRequest?
    let weeks: [CalendarWeek]
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
    let onTopWeekChange: (String?) -> Void

    init(
        initialScrollWeekID: String?,
        scrollRequest: CalendarScrollRequest?,
        weeks: [CalendarWeek],
        focusedMonthID: String?,
        showLunarCalendar: Bool,
        showSolarTerms: Bool,
        showPublicHolidays: Bool,
        showWeekNumbers: Bool,
        selectedDayID: String,
        currentDayID: String,
        accentColor: Color,
        holidayColor: Color,
        workdayColor: Color,
        festivalColor: Color,
        solarTermColor: Color,
        onSelectDay: @escaping (CalendarDay) -> Void,
        onTopWeekChange: @escaping (String?) -> Void
    ) {
        var initialPosition = ScrollPosition(idType: String.self)
        if let initialScrollWeekID {
            initialPosition.scrollTo(id: initialScrollWeekID, anchor: .top)
        }
        _scrollPosition = State(initialValue: initialPosition)
        self.initialScrollWeekID = initialScrollWeekID
        self.scrollRequest = scrollRequest
        self.weeks = weeks
        self.focusedMonthID = focusedMonthID
        self.showLunarCalendar = showLunarCalendar
        self.showSolarTerms = showSolarTerms
        self.showPublicHolidays = showPublicHolidays
        self.showWeekNumbers = showWeekNumbers
        self.selectedDayID = selectedDayID
        self.currentDayID = currentDayID
        self.accentColor = accentColor
        self.holidayColor = holidayColor
        self.workdayColor = workdayColor
        self.festivalColor = festivalColor
        self.solarTermColor = solarTermColor
        self.onSelectDay = onSelectDay
        self.onTopWeekChange = onTopWeekChange
    }

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
                        currentDayID: currentDayID,
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
        .overlayScrollerStyle()
        .frame(height: CalendarGridLayout.gridHeight)
        .onChange(of: scrollPosition.viewID(type: String.self)) { _, topWeekID in
            onTopWeekChange(topWeekID)
        }
        .onChange(of: scrollRequest) { _, request in
            guard let request else { return }
            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = request.disablesAnimations
            withTransaction(transaction) {
                scrollPosition.scrollTo(id: request.weekID, anchor: .top)
            }
        }
    }
}
