//
//  WeekdayHeaderView.swift
//  MenuCal
//
//  Created by gp on 2026/6/4.
//

import SwiftUI

struct WeekdayHeaderView: View {
    let weekStartDay: WeekStartDay
    let showWeekNumbers: Bool

    var body: some View {
        HStack(spacing: 0) {
            if showWeekNumbers {
                Text("#")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: CalendarGridLayout.weekNumberColumnWidth)
            }

            ForEach(weekStartDay.weekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption)
                    .frame(width: CalendarGridLayout.dayCellSize)
            }
        }
        .padding(.trailing, CalendarGridLayout.trailingPadding)
        .frame(maxWidth: .infinity)
    }
}
