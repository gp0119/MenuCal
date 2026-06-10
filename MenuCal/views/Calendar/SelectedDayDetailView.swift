import SwiftUI

struct SelectedDayDetailView: View {
    let day: CalendarDay
    let showPublicHolidays: Bool

    private var lunarText: String {
        LunarDateFormatter.shared.lunarDate(for: day.date)
    }

    private var festivalText: String? {
        LunarDateFormatter.shared.festivalText(for: day.date)
    }

    private var solarTermText: String? {
        LunarDateFormatter.shared.solarTermText(for: day.date)
    }

    private var lunarDetailText: String {
        [lunarText, festivalText, solarTermText]
            .compactMap { text in
                guard let text, !text.isEmpty else { return nil }
                return text
            }
            .joined(separator: " · ")
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

                if !lunarDetailText.isEmpty {
                    Text(lunarDetailText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }

            Spacer()

            if let holidayText {
                Text(holidayText)
                    .font(.caption)
                    .foregroundStyle(day.publicHolidayKind == .holiday ? Color.red : Color.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
