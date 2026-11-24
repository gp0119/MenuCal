//
//  SettingsView.swift
//  MenuCal
//
//  Created by gp on 2026/6/4.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("通用", systemImage: "gearshape") {
                GeneralSettingsView()
            }

            // Tab("窗口", systemImage: "macwindow") {
            //     WindowSettingsView()
            // }

            Tab("菜单栏", systemImage: "menubar.rectangle") {
                MenuBarSettingsView()
            }

            Tab("日历", systemImage: "calendar") {
                CalendarSettingsView()
            }
        }
        .frame(width: 440, height: 480)
    }
}
