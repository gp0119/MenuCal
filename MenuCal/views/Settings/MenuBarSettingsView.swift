//
//  MenuBarSettingsView.swift
//  MenuCal
//
//  Created by gp on 2026/6/8.
//

import SwiftUI

struct MenuBarSettingsView: View {
    @EnvironmentObject private var store: SettingsStore

    var body: some View {
        List {
            Section {
                ForEach($store.menuBar.items) { $item in
                    Toggle(item.component.displayName, isOn: $item.isEnabled)
                        .toggleStyle(.checkbox)
                }
                .onMove { source, destination in
                    store.menuBar.items.move(fromOffsets: source, toOffset: destination)
                }
            } header: {
                Text("显示内容")
            } footer: {
                Text("勾选要在菜单栏显示的内容，拖动可调整顺序。")
                    .foregroundStyle(.secondary)
            }

            Section {
                Picker("图标样式", selection: $store.menuBar.iconStyle) {
                    ForEach(MenuBarIconStyle.allCases) { style in
                        Label {
                            Text(style.displayName)
                        } icon: {
                            iconPreview(style)
                        }
                        .tag(style)
                    }
                }
                .disabled(!isIconEnabled)
            }

            Section {
                Toggle("显示秒", isOn: $store.menuBar.showSeconds)
                    .disabled(!isTimeEnabled)
            }
        }
    }

    @ViewBuilder
    private func iconPreview(_ style: MenuBarIconStyle) -> some View {
        if let glyph = MenuBarLabelBuilder.iconGlyphText(for: style, date: Date()) {
            Image(nsImage: MenuBarIconImage.glyph(glyph))
        } else {
            Image(systemName: "calendar")
        }
    }

    private var isIconEnabled: Bool {
        store.menuBar.items.contains { $0.component == .icon && $0.isEnabled }
    }

    private var isTimeEnabled: Bool {
        store.menuBar.items.contains { $0.component == .time && $0.isEnabled }
    }
}
