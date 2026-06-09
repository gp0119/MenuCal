//
//  MenuBarIconStyle.swift
//  MenuCal
//
//  Created by gp on 2026/6/8.
//

import Foundation

enum MenuBarIconStyle: String, CaseIterable, Codable, Identifiable, Sendable {
    case calendar
    case dayOfMonth
    case weekday

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .calendar: "日历图标"
        case .dayOfMonth: "当天日期"
        case .weekday: "星期"
        }
    }
}
