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
    let accentColor: Color
    @Environment(\.openSettings) private var openSettings
    @State private var isPickerPresented = false
    @State private var canCheckForUpdates = false

    var body: some View {
        CalendarControlRow {
            Button {
                isPickerPresented = true
            } label: {
                monthButtonLabel
            }
            .buttonStyle(.plain)
            .accessibilityHint("跳转到指定年月")
            .help("跳转到指定年月")
            .popover(isPresented: $isPickerPresented, arrowEdge: .bottom) {
                MonthYearPickerView(
                    selectedYear: month.year,
                    selectedMonth: month.month,
                    accentColor: accentColor
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
            .accessibilityLabel("返回今天")
            .help("返回今天")

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
            .menuIndicator(.hidden)
            .buttonStyle(HoverIconButtonStyle())
            .accessibilityLabel("更多选项")
        }
        .onReceive(updater.publisher(for: \.canCheckForUpdates)) {
            canCheckForUpdates = $0
        }
    }

    @ViewBuilder
    private var monthButtonLabel: some View {
        let title = Text(String(format: "%04d年 %d月", month.year, month.month))

        if #available(macOS 26, *) {
            HStack(spacing: 6) {
                title
                    .font(.headline.monospacedDigit())

                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 12)
            .frame(height: 28)
            .contentShape(Capsule())
            .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            title
                .font(.title3)
                .foregroundStyle(.primary)
                .frame(width: 90, alignment: .leading)
                .contentShape(Rectangle())
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

private struct CalendarControlRow<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        if #available(macOS 26, *) {
            GlassEffectContainer(spacing: 8) {
                HStack(spacing: 8) { content }
            }
        } else {
            HStack { content }
        }
    }
}

private struct MonthYearPickerView: View {
    let selectedYear: Int
    let selectedMonth: Int
    let accentColor: Color
    let onSelect: (Int, Int) -> Void

    @State private var year: Int

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    init(
        selectedYear: Int,
        selectedMonth: Int,
        accentColor: Color,
        onSelect: @escaping (Int, Int) -> Void
    ) {
        self.selectedYear = selectedYear
        self.selectedMonth = selectedMonth
        self.accentColor = accentColor
        self.onSelect = onSelect
        _year = State(initialValue: selectedYear)
    }

    var body: some View {
        VStack(spacing: 12) {
            CalendarControlRow {
                Button {
                    year -= 1
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(HoverIconButtonStyle())
                .accessibilityLabel("上一年")
                .help("上一年")

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
                .accessibilityLabel("下一年")
                .help("下一年")
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
                                    .fill(isSelected ? accentColor.opacity(0.2) : Color.clear)
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
