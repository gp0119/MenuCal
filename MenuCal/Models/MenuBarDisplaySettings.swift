//
//  MenuBarDisplaySettings.swift
//  MenuCal
//
//  Created by gp on 2026/6/8.
//

import Foundation

struct MenuBarItem: Codable, Identifiable, Sendable {
    let component: MenuBarComponent
    var isEnabled: Bool

    var id: MenuBarComponent { component }
}

struct MenuBarDisplaySettings: Codable, Sendable {
    var items: [MenuBarItem]
    var showSeconds: Bool
    var iconStyle: MenuBarIconStyle

    static let `default` = MenuBarDisplaySettings(
        items: MenuBarComponent.allCases.map {
            MenuBarItem(component: $0, isEnabled: $0 == .icon || $0 == .date)
        },
        showSeconds: false,
        iconStyle: .calendar
    )

    init(items: [MenuBarItem], showSeconds: Bool, iconStyle: MenuBarIconStyle) {
        self.items = items
        self.showSeconds = showSeconds
        self.iconStyle = iconStyle
    }

    // Tolerate older stored data that predates newer fields so a settings upgrade
    // doesn't discard the user's saved layout.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decode([MenuBarItem].self, forKey: .items)
        showSeconds = try container.decodeIfPresent(Bool.self, forKey: .showSeconds) ?? false
        iconStyle = try container.decodeIfPresent(MenuBarIconStyle.self, forKey: .iconStyle) ?? .calendar
    }

    // Keep stored data forward-compatible: append any components added after the
    // settings were last saved (disabled by default) without dropping user order.
    func normalized() -> MenuBarDisplaySettings {
        let existing = Set(items.map(\.component))
        let missing = MenuBarComponent.allCases
            .filter { !existing.contains($0) }
            .map { MenuBarItem(component: $0, isEnabled: false) }
        return MenuBarDisplaySettings(items: items + missing, showSeconds: showSeconds, iconStyle: iconStyle)
    }
}
