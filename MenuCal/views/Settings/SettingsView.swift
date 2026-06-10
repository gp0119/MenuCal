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
            GeneralSettingsView()
                .tabItem {
                    Label("通用", systemImage: "gearshape")
                }

            // WindowSettingsView()
            //     .tabItem {
            //         Label("窗口", systemImage: "macwindow")
            //     }

            MenuBarSettingsView()
                .tabItem {
                    Label("菜单栏", systemImage: "menubar.rectangle")
                }

            CalendarSettingsView()
                .tabItem {
                    Label("日历", systemImage: "calendar")
                }
        }
        .frame(width: 440, height: 480)
    }
}
