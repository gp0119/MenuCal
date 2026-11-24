import SwiftUI

struct SelectedDayDetailView: View {
    let day: CalendarDay
    let showLunarCalendar: Bool
    let showSolarTerms: Bool
    let showPublicHolidays: Bool
    let holidayColor: Color
    let workdayColor: Color
    let festivalColor: Color
    let solarTermColor: Color

    private var secondaryText: Text? {
        let formatter = LunarDateFormatter.shared
        let lunar = showLunarCalendar ? formatter.lunarDate(for: day.date) : ""
        let festival = showLunarCalendar ? formatter.festivalText(for: day.date) : nil
        let solarTerm = showSolarTerms ? formatter.solarTermText(for: day.date) : nil
        let parts = [
            lunar.isEmpty ? nil : Text(lunar),
            festival.map { Text($0).foregroundStyle(festivalColor) },
            solarTerm.map { Text($0).foregroundStyle(solarTermColor) },
        ].compactMap { $0 }

        guard let first = parts.first else { return nil }
        return parts.dropFirst().reduce(first) { text, part in Text("\(text) · \(part)") }
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(day.formattedDate) · 第\(day.weekOfYear)周")
                    .font(.headline)

                if let secondaryText {
                    secondaryText
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }

            Spacer()

            if showPublicHolidays, let holidayKind = day.publicHolidayKind {
                Text(holidayKind.displayName)
                    .font(.caption)
                    .foregroundStyle(holidayKind == .holiday ? holidayColor : workdayColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
