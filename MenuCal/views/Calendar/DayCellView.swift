import SwiftUI

struct DayCellView: View {
    let day: CalendarDay
    let focusedMonthID: String?
    let showLunarCalendar: Bool
    let showSolarTerms: Bool
    let showPublicHolidays: Bool
    let isSelected: Bool
    let isToday: Bool
    let accentColor: Color
    let holidayColor: Color
    let workdayColor: Color
    let festivalColor: Color
    let solarTermColor: Color
    let onSelect: (CalendarDay) -> Void

    private var secondaryContent: (text: String, markerColor: Color?)? {
        let formatter = LunarDateFormatter.shared
        if showLunarCalendar, let festival = formatter.festivalText(for: day.date) {
            return (festival, festivalColor)
        }
        if showSolarTerms, let solarTerm = formatter.solarTermText(for: day.date) {
            return (solarTerm, solarTermColor)
        }
        if showLunarCalendar {
            let lunar = formatter.lunarDay(for: day.date)
            return lunar.isEmpty ? nil : (lunar, nil)
        }
        return nil
    }

    var body: some View {
        let secondaryContent = secondaryContent
        let holidayKind = showPublicHolidays ? day.publicHolidayKind : nil
        let holidayTint = holidayKind.map { $0 == .holiday ? holidayColor : workdayColor }
        let isEmphasized = isToday || isSelected || day.monthID == focusedMonthID
        let cellShape = RoundedRectangle(cornerRadius: 8, style: .continuous)

        Button {
            onSelect(day)
        } label: {
            VStack(spacing: 1) {
                Text("\(day.day)")
                    .font(.body.monospacedDigit())
                    .fontWeight(isToday || isSelected ? .semibold : .regular)
                    .foregroundStyle(isEmphasized ? .primary : .secondary)

                if let secondaryContent {
                    Text(secondaryContent.text)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .opacity(isEmphasized ? 1 : 0.8)
            .frame(
                width: CalendarGridLayout.dayContentSize,
                height: CalendarGridLayout.dayContentSize
            )
            .background(cellBackground(holidayTint: holidayTint), in: cellShape)
            .overlay {
                if isToday {
                    cellShape.strokeBorder(accentColor, lineWidth: 1.5)
                }
            }
            .overlay(alignment: .bottom) {
                if let markerColor = secondaryContent?.markerColor {
                    Capsule()
                        .fill(markerColor)
                        .frame(width: 10, height: 2)
                        .padding(.bottom, 1)
                }
            }
            .overlay(alignment: .topLeading) {
                if let holidayKind {
                    Text(holidayKind == .holiday ? "休" : "班")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                        .opacity(isEmphasized ? 1 : 0.8)
                        .padding([.top, .leading], 2)
                }
            }
            .frame(
                width: CalendarGridLayout.dayCellSize,
                height: CalendarGridLayout.dayCellSize
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(day.formattedDate)
        .accessibilityValue(
            [isToday ? "今天" : nil, holidayKind?.displayName, secondaryContent?.text]
                .compactMap { $0 }
                .joined(separator: "，")
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func cellBackground(holidayTint: Color?) -> Color {
        if isToday {
            return accentColor.opacity(isSelected ? 0.24 : 0.12)
        }
        if let holidayTint {
            let opacity = day.monthID == focusedMonthID ? 0.14 : 0.08
            return holidayTint.opacity(isSelected ? 0.24 : opacity)
        }
        return isSelected ? Color.primary.opacity(0.12) : .clear
    }
}
