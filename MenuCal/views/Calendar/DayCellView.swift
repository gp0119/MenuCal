import SwiftUI

struct DayCellView: View {
    let day: CalendarDay
    let focusedMonthID: String?
    let showLunarCalendar: Bool
    let showSolarTerms: Bool
    let isSelected: Bool
    let onSelect: (CalendarDay) -> Void

    private var isInFocusedMonth: Bool {
        day.monthID == focusedMonthID
    }

    private var secondaryText: String {
        LunarDateFormatter.shared.shortText(
            for: day.date,
            showLunarCalendar: showLunarCalendar,
            showSolarTerms: showSolarTerms
        )
    }

    var body: some View {
        Button {
            onSelect(day)
        } label: {
            ZStack(alignment: .topLeading) {
                if let fill = cellBackgroundFill {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(fill)
                }

                if day.isToday, !isSelected {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.accentColor, lineWidth: 1)
                }

                if secondaryText.isEmpty {
                    Text("\(day.day)")
                        .font(.body)
                        .foregroundStyle(foregroundStyle)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 1) {
                        Text("\(day.day)")
                            .font(.body)
                            .foregroundStyle(foregroundStyle)
                        Text(secondaryText)
                            .font(.system(size: 9))
                            .foregroundStyle(lunarForegroundStyle)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                if let badge = holidayBadgeText {
                    Text(badge)
                        .font(.system(size: 7))
                        .foregroundStyle(foregroundStyle)
                        .padding(.top, 2)
                        .padding(.leading, 3)
                }
            }
            .frame(width: 36, height: 38)
            .frame(maxWidth: .infinity)
            .frame(height: CalendarGridLayout.dayCellHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var holidayBadgeText: String? {
        switch day.publicHolidayKind {
        case .holiday: "休"
        case .workday: "班"
        case nil: nil
        }
    }

    private var cellBackgroundFill: Color? {
        if isSelected {
            return Color.accentColor
        }
        if day.isToday {
            return Color.accentColor.opacity(0.12)
        }
        let emphasis = isInFocusedMonth ? 1.0 : 0.55
        switch day.publicHolidayKind {
        case .holiday: return Color.red.opacity(0.14 * emphasis)
        case .workday: return Color.orange.opacity(0.14 * emphasis)
        case nil: return nil
        }
    }

    private var foregroundStyle: AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(.white)
        }
        if day.isToday {
            return AnyShapeStyle(Color.accentColor)
        }
        if isInFocusedMonth {
            switch day.publicHolidayKind {
            case .holiday: return AnyShapeStyle(Color.red)
            case .workday: return AnyShapeStyle(Color.orange)
            case nil: return AnyShapeStyle(.primary)
            }
        }
        return AnyShapeStyle(.tertiary)
    }

    private var lunarForegroundStyle: AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(.white)
        }
        if day.isToday {
            return AnyShapeStyle(Color.accentColor)
        }
        if isInFocusedMonth {
            return AnyShapeStyle(.secondary)
        }
        return AnyShapeStyle(.tertiary)
    }
}
