import Foundation

struct CalendarDay: Identifiable, Hashable, Sendable {
    let id: String
    let monthID: String
    let date: Date
    let day: Int
    let weekOfYear: Int
    let isToday: Bool
    let publicHolidayKind: PublicHolidayKind?

    init(
        date: Date,
        day: Int,
        isToday: Bool,
        publicHolidayKind: PublicHolidayKind? = nil,
        calendar: Calendar = .current
    ) {
        self.date = date
        self.day = day
        self.weekOfYear = calendar.component(.weekOfYear, from: date)
        self.isToday = isToday
        self.publicHolidayKind = publicHolidayKind

        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.monthID = String(format: "%04d-%02d", components.year!, components.month!)
        self.id = String(format: "%04d-%02d-%02d", components.year!, components.month!, components.day!)
    }
}
