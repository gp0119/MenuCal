import SwiftUI

struct SelectedDayDetailView: View {
    let day: CalendarDay
    let showPublicHolidays: Bool
    let holidayColor: Color
    let workdayColor: Color
    let festivalColor: Color
    let solarTermColor: Color

    private var lunarText: String {
        LunarDateFormatter.shared.lunarDate(for: day.date)
    }

    private var festivalText: String? {
        LunarDateFormatter.shared.festivalText(for: day.date)
    }

    private var solarTermText: String? {
        LunarDateFormatter.shared.solarTermText(for: day.date)
    }

    private var holidayText: String? {
        guard showPublicHolidays else { return nil }

        return switch day.publicHolidayKind {
        case .holiday: "休息日"
        case .workday: "调休上班"
        case nil: nil
        }
    }

    private var dateText: String {
        let date = day.date.formatted(
            .dateTime
                .locale(Locale(identifier: "zh_CN"))
                .year()
                .month()
                .day()
                .weekday(.wide)
        )

        return "\(date) · 第\(day.weekOfYear)周"
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(dateText)
                    .font(.headline)

                HStack(spacing: 4) {
                    Text(lunarText)
                        .foregroundStyle(.secondary)

                    if let festivalText, !festivalText.isEmpty {
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text(festivalText)
                            .foregroundStyle(festivalColor)
                    }

                    if let solarTermText, !solarTermText.isEmpty {
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text(solarTermText)
                            .foregroundStyle(solarTermColor)
                    }
                }
                .font(.callout)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }

            Spacer()

            if let holidayText {
                Text(holidayText)
                    .font(.caption)
                    .foregroundStyle(
                        day.publicHolidayKind == .holiday ? holidayColor : workdayColor
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
