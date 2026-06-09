import Foundation

struct CalendarMonth: Identifiable, Hashable, Sendable {
    let id: String
    let startDate: Date
    let year: Int
    let month: Int

    init(startDate: Date, calendar: Calendar) {
        self.startDate = startDate
        let components = calendar.dateComponents([.year, .month], from: startDate)
        self.year = components.year!
        self.month = components.month!
        self.id = String(format: "%04d-%02d", year, month)
    }
}
