import Foundation

struct CalendarWeek: Identifiable, Hashable, Sendable {
    // Stable id is the week's start day ("YYYY-MM-DD"). It changes when the user
    // switches the week-start day, which is intended: callers re-anchor by month.
    let id: String
    // Owning month (the month holding the majority of the week's days), used to
    // drive the header title and month-level jumps.
    let monthID: String
    let days: [CalendarDay]
}
