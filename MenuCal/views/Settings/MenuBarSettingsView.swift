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
                    HStack(spacing: 12) {
                        Toggle(item.component.displayName, isOn: $item.isEnabled)
                            .toggleStyle(.checkbox)

                        Spacer()

                        if item.component == .icon {
                            Picker("图标样式", selection: $store.menuBar.iconStyle) {
                                ForEach(MenuBarIconStyle.allCases) { style in
                                    iconPreview(style)
                                        .tag(style)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                            .frame(width: 52)
                            .disabled(!item.isEnabled)
                            .opacity(item.isEnabled ? 1 : 0.55)
                        }

                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.tertiary)
                            .help("拖动调整顺序")
                    }
                    .padding(.vertical, 2)
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
                Toggle("显示秒", isOn: $store.menuBar.showSeconds)
                    .disabled(!isTimeEnabled)
                    .opacity(isTimeEnabled ? 1 : 0.55)
            } header: {
                Text("时间")
            } footer: {
                if !isTimeEnabled {
                    Text("启用“时间”后可显示秒数。")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.inset)
    }

    @ViewBuilder
    private func iconPreview(_ style: MenuBarIconStyle) -> some View {
        if let glyph = MenuBarLabelBuilder.iconGlyphText(for: style, date: Date()) {
            Image(nsImage: MenuBarIconImage.glyph(glyph))
        } else {
            Image(systemName: "calendar")
        }
    }

    private var isTimeEnabled: Bool {
        store.menuBar.items.contains { $0.component == .time && $0.isEnabled }
    }
}
