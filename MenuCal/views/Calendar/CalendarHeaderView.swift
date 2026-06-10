//
//  CalendarHeaderView.swift
//  MenuCal
//
//  Created by gp on 2026/6/4.
//

import AppKit
import Combine
import Sparkle
import SwiftUI

struct CalendarHeaderView: View {
    let month: CalendarMonth
    let onGoToToday: () -> Void
    let onSelectMonth: (Int, Int) -> Void
    let updater: SPUUpdater
    @Environment(\.openSettings) private var openSettings
    @State private var isPickerPresented = false
    @State private var canCheckForUpdates = false

    var body: some View {
        HStack {
            Button {
                isPickerPresented = true
            } label: {
                Text(String(format: "%04d年 %d月", month.year, month.month))
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .frame(width: 90, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isPickerPresented, arrowEdge: .bottom) {
                MonthYearPickerView(
                    selectedYear: month.year,
                    selectedMonth: month.month
                ) { year, monthValue in
                    isPickerPresented = false
                    onSelectMonth(year, monthValue)
                }
            }

            Spacer()

            Button(action: onGoToToday) {
                Image(systemName: "arrow.uturn.backward")
            }
            .buttonStyle(HoverIconButtonStyle())

            Menu {
                Button {
                    showSettings()
                } label: {
                    Label("设置", systemImage: "gearshape")
                }

                Button {
                    updater.checkForUpdates()
                } label: {
                    Label("检查更新", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(!canCheckForUpdates)

                Button {
                    showAbout()
                } label: {
                    Label("关于", systemImage: "info.circle")
                }

                Divider()

                Button(role: .destructive) {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label("退出", systemImage: "power")
                }
            } label: {
                Image(systemName: "ellipsis")
            }
            .buttonStyle(HoverIconButtonStyle())
        }
        .onReceive(updater.publisher(for: \.canCheckForUpdates)) {
            canCheckForUpdates = $0
        }
    }

    private func showSettings() {
        bringAppToFront()
        openSettings()

        DispatchQueue.main.async {
            bringAppToFront()
        }
    }

    private func showAbout() {
        bringAppToFront()
        NSApplication.shared.orderFrontStandardAboutPanel(nil)
    }

    private func bringAppToFront() {
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}

private struct MonthYearPickerView: View {
    let selectedYear: Int
    let selectedMonth: Int
    let onSelect: (Int, Int) -> Void

    @State private var year: Int

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    init(selectedYear: Int, selectedMonth: Int, onSelect: @escaping (Int, Int) -> Void) {
        self.selectedYear = selectedYear
        self.selectedMonth = selectedMonth
        self.onSelect = onSelect
        _year = State(initialValue: selectedYear)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    year -= 1
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(HoverIconButtonStyle())

                Spacer()

                Text(String(format: "%04d", year))
                    .font(.headline)

                Spacer()

                Button {
                    year += 1
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(HoverIconButtonStyle())
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...12, id: \.self) { monthValue in
                    let isSelected = year == selectedYear && monthValue == selectedMonth
                    Button {
                        onSelect(year, monthValue)
                    } label: {
                        Text("\(monthValue)月")
                            .font(.callout)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .frame(width: 240)
    }
}
