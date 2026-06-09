//
//  MenuBarComponent.swift
//  MenuCal
//
//  Created by gp on 2026/6/8.
//

import Foundation

enum MenuBarComponent: String, CaseIterable, Codable, Identifiable, Sendable {
    case icon
    case year
    case lunarYear
    case lunarDay
    case date
    case weekday
    case time

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .icon: "图标"
        case .year: "年份"
        case .lunarYear: "农历年"
        case .lunarDay: "农历日"
        case .date: "日期"
        case .weekday: "星期"
        case .time: "时间"
        }
    }
}
