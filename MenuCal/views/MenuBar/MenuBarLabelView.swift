//
//  MenuBarLabelView.swift
//  MenuCal
//
//  Created by gp on 2026/6/8.
//

import AppKit
import Combine
import SwiftUI

struct MenuBarLabelView: View {
    @EnvironmentObject private var store: SettingsStore
    @State private var now = Date()

    // The menu bar status item renders a SwiftUI Text label through its plain
    // string title and drops inline image attachments, so the whole label (icon +
    // text) is baked into one template image. Refreshed by a timer rather than
    // TimelineView, which can drop the whole item.
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        let segments = MenuBarLabelBuilder.segments(
            for: store.menuBar,
            date: now,
            uses24HourTime: store.uses24HourTime,
            showsAMPM: store.showsAMPM
        )
        Image(nsImage: MenuBarIconImage.label(segments))
            .onReceive(timer) { now = $0 }
    }
}
