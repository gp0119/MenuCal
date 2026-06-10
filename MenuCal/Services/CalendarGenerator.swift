import Foundation

struct CalendarGenerator {
    let calendar: Calendar
    private let holidayCalendar: HolidayCalendarService

    init(calendar: Calendar = .current, holidayCalendar: HolidayCalendarService = .shared) {
        self.calendar = calendar
        self.holidayCalendar = holidayCalendar
    }

    func months(around date: Date = .now, past: Int = 30, future: Int = 29) -> [CalendarMonth] {
        guard let anchor = startOfMonth(for: date) else { return [] }

        return (-past...future).compactMap { offset in
            guard let monthDate = calendar.date(byAdding: .month, value: offset, to: anchor) else {
                return nil
            }
            return CalendarMonth(startDate: monthDate, calendar: calendar)
        }
    }

    func month(containing date: Date = .now) -> CalendarMonth? {
        guard let anchor = startOfMonth(for: date) else { return nil }
        return CalendarMonth(startDate: anchor, calendar: calendar)
    }

    func weeks(
        around date: Date = .now,
        past: Int = 30,
        future: Int = 29,
        weekStartDay: WeekStartDay = .sunday,
        today: Date = .now
    ) -> [CalendarWeek] {
        var calendar = calendar
        calendar.firstWeekday = weekStartDay.firstWeekday

        let columns = CalendarGridLayout.columnCount

        guard
            let anchorMonth = startOfMonth(for: date),
            let firstMonthStart = calendar.date(byAdding: .month, value: -past, to: anchorMonth),
            let lastMonthStart = calendar.date(byAdding: .month, value: future, to: anchorMonth),
            let lastMonthEnd = calendar.date(
                byAdding: DateComponents(month: 1, day: -1), to: lastMonthStart)
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstMonthStart)
        let leadingDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        guard
            let gridStart = calendar.date(byAdding: .day, value: -leadingDays, to: firstMonthStart)
        else {
            return []
        }

        var result: [CalendarWeek] = []
        var weekStart = gridStart
        // Weeks tile continuously (no gaps, no repeats); a week's owning month is
        // the month of its 4th day, which holds the majority of the week's days.
        while weekStart <= lastMonthEnd {
            var days: [CalendarDay] = []
            for col in 0..<columns {
                guard let date = calendar.date(byAdding: .day, value: col, to: weekStart) else {
                    continue
                }
                days.append(
                    CalendarDay(
                        date: date,
                        day: calendar.component(.day, from: date),
                        isToday: calendar.isDate(date, inSameDayAs: today),
                        publicHolidayKind: holidayCalendar.kind(for: date),
                        calendar: calendar
                    )
                )
            }

            let majorityDate = calendar.date(byAdding: .day, value: 3, to: weekStart) ?? weekStart
            let startComponents = calendar.dateComponents([.year, .month, .day], from: weekStart)
            let monthComponents = calendar.dateComponents([.year, .month], from: majorityDate)
            result.append(
                CalendarWeek(
                    id: String(
                        format: "%04d-%02d-%02d",
                        startComponents.year!, startComponents.month!, startComponents.day!),
                    monthID: String(
                        format: "%04d-%02d", monthComponents.year!, monthComponents.month!),
                    days: days
                )
            )

            guard let next = calendar.date(byAdding: .day, value: columns, to: weekStart) else {
                break
            }
            weekStart = next
        }
        return result
    }

    private func startOfMonth(for date: Date) -> Date? {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)
    }
}
