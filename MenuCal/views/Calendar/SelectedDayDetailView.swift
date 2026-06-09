import SwiftUI

struct SelectedDayDetailView: View {
    let day: CalendarDay

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
        switch day.publicHolidayKind {
        case .holiday: "休息日"
        case .workday: "调休上班"
        case nil: nil
        }
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(
                    day.date.formatted(
                        .dateTime
                            .locale(Locale(identifier: "zh_CN"))
                            .year()
                            .month()
                            .day()
                            .weekday(.wide)
                    )
                )
                .font(.headline)

                if !lunarText.isEmpty {
                    Text("农历 \(lunarText)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                if festivalText != nil || solarTermText != nil {
                    HStack(spacing: 12) {
                        if let festivalText {
                            Text("节日 \(festivalText)")
                        }
                        if let solarTermText {
                            Text("节气 \(solarTermText)")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
