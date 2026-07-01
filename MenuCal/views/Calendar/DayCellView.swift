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

    private enum SecondaryTextKind {
        case festival
        case solarTerm
        case lunar
    }

    private var isInFocusedMonth: Bool {
        day.monthID == focusedMonthID
    }

    private var secondaryContent: (text: String, kind: SecondaryTextKind)? {
        let formatter = LunarDateFormatter.shared
        if showLunarCalendar, let festival = formatter.festivalText(for: day.date) {
            return (festival, .festival)
        }
        if showSolarTerms, let solarTerm = formatter.solarTermText(for: day.date) {
            return (solarTerm, .solarTerm)
        }
        if showLunarCalendar {
            let lunar = formatter.lunarDay(for: day.date)
            return lunar.isEmpty ? nil : (lunar, .lunar)
        }
        return nil
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

                if isToday, !isSelected {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(accentColor, lineWidth: 1)
                }

                if let secondaryContent {
                    VStack(spacing: 1) {
                        Text("\(day.day)")
                            .font(.body)
                            .foregroundStyle(foregroundStyle)
                        Text(secondaryContent.text)
                            .font(.system(size: 9))
                            .foregroundStyle(
                                secondaryForegroundStyle(for: secondaryContent.kind)
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("\(day.day)")
                        .font(.body)
                        .foregroundStyle(foregroundStyle)
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
            .frame(
                width: CalendarGridLayout.dayContentSize,
                height: CalendarGridLayout.dayContentSize
            )
            .frame(
                width: CalendarGridLayout.dayCellSize,
                height: CalendarGridLayout.dayCellSize
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var holidayBadgeText: String? {
        switch displayedHolidayKind {
        case .holiday: "休"
        case .workday: "班"
        case nil: nil
        }
    }

    private var displayedHolidayKind: PublicHolidayKind? {
        showPublicHolidays ? day.publicHolidayKind : nil
    }

    private var cellBackgroundFill: Color? {
        if isSelected {
            if isToday {
                return accentColor
            }
            return Color.gray.opacity(0.2)
        }
        if isToday {
            return accentColor.opacity(0.12)
        }
        let emphasis = isInFocusedMonth ? 1.0 : 0.55
        switch displayedHolidayKind {
        case .holiday: return holidayColor.opacity(0.14 * emphasis)
        case .workday: return workdayColor.opacity(0.14 * emphasis)
        case nil: return nil
        }
    }

    private var foregroundStyle: AnyShapeStyle {
        if isSelected {
            if isToday {
                return AnyShapeStyle(.white)
            }
            return AnyShapeStyle(.primary)
        }
        if isToday {
            return AnyShapeStyle(accentColor)
        }
        if isInFocusedMonth {
            switch displayedHolidayKind {
            case .holiday: return AnyShapeStyle(holidayColor)
            case .workday: return AnyShapeStyle(workdayColor)
            case nil: return AnyShapeStyle(.primary)
            }
        }
        return AnyShapeStyle(.tertiary)
    }

    private func secondaryForegroundStyle(for kind: SecondaryTextKind) -> AnyShapeStyle {
        if isSelected {
            if isToday {
                return AnyShapeStyle(.white)
            }
        }

        let emphasis = isInFocusedMonth ? 1.0 : 0.55
        switch kind {
        case .festival:
            return AnyShapeStyle(festivalColor.opacity(emphasis))
        case .solarTerm:
            return AnyShapeStyle(solarTermColor.opacity(emphasis))
        case .lunar:
            return AnyShapeStyle(isInFocusedMonth ? Color.secondary : Color.secondary.opacity(0.55))
        }
    }
}
