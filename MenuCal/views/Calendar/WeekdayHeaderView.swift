//
//  WeekdayHeaderView.swift
//  MenuCal
//
//  Created by gp on 2026/6/4.
//

import SwiftUI

struct WeekdayHeaderView: View {
    let weekStartDay: WeekStartDay

    var body: some View {
        HStack {
            ForEach(weekStartDay.weekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
