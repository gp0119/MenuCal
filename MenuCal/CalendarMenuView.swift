import Combine
import Sparkle
import SwiftUI

@MainActor
private final class CalendarMenuModel: ObservableObject {
    let weeks: [CalendarWeek]
    let today: CalendarDay
    let fallbackMonth: CalendarMonth
    let monthsByID: [String: CalendarMonth]
    let weekIndexByID: [String: Int]
    let firstDayWeekIDByMonthID: [String: String]

    init(weekStartDay: WeekStartDay) {
        let generator = CalendarGenerator()
        let weeks = generator.weeks(weekStartDay: weekStartDay)
        self.weeks = weeks
        today = weeks.lazy.flatMap(\.days).first(where: \.isToday)!

        var weekIndexByID: [String: Int] = [:]
        var firstDayWeekIDByMonthID: [String: String] = [:]
        for (index, week) in weeks.enumerated() {
            weekIndexByID[week.id] = index
            for day in week.days where day.day == 1 {
                firstDayWeekIDByMonthID[day.monthID] = week.id
            }
        }
        self.weekIndexByID = weekIndexByID
        self.firstDayWeekIDByMonthID = firstDayWeekIDByMonthID

        let months = generator.months()
        monthsByID = Dictionary(uniqueKeysWithValues: months.map { ($0.id, $0) })
        fallbackMonth = generator.month(containing: .now) ?? months[months.count / 2]
    }
}

struct CalendarMenuView: View {
    @EnvironmentObject private var store: SettingsStore

    private let weekStartDay: WeekStartDay
    private let updater: SPUUpdater
    @StateObject private var model: CalendarMenuModel

    // Focus the month a few rows below the top-most week so the next month
    // lights up while it is still scrolling into view, rather than only once
    // its 1st reaches the very top.
    private static let monthFocusLookahead = 2

    @State private var scrollPosition: ScrollPosition
    @State private var selectedDay: CalendarDay

    init(weekStartDay: WeekStartDay = .sunday, updater: SPUUpdater) {
        self.weekStartDay = weekStartDay
        self.updater = updater
        let model = CalendarMenuModel(weekStartDay: weekStartDay)
        _model = StateObject(wrappedValue: model)

        _scrollPosition = State(initialValue: ScrollPosition(idType: String.self))
        _selectedDay = State(initialValue: model.today)
    }

    private var visibleMonth: CalendarMonth {
        guard
            let topWeekID = scrollPosition.viewID(type: String.self),
            let topIndex = model.weekIndexByID[topWeekID]
        else {
            return model.fallbackMonth
        }
        let focusIndex = min(topIndex + Self.monthFocusLookahead, model.weeks.count - 1)
        let monthID = model.weeks[focusIndex].monthID
        return model.monthsByID[monthID] ?? model.fallbackMonth
    }

    private func scrollToMonth(year: Int, month: Int) {
        let monthID = String(format: "%04d-%02d", year, month)
        guard let weekID = model.firstDayWeekIDByMonthID[monthID] else { return }
        scrollPosition.scrollTo(id: weekID, anchor: .top)
    }

    private func resetToCurrentMonth() {
        selectedDay = model.today
        guard
            let todayMonth = CalendarGenerator().month(containing: .now),
            let weekID = model.firstDayWeekIDByMonthID[todayMonth.id]
        else { return }
        // Uniform week-row heights let a single scrollTo land exactly on the week
        // holding the month's 1st, even when it is already top-most.
        scrollPosition.scrollTo(id: weekID, anchor: .top)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CalendarHeaderView(
                month: visibleMonth,
                onGoToToday: resetToCurrentMonth,
                onSelectMonth: scrollToMonth,
                updater: updater
            )
            .padding(.trailing, CalendarGridLayout.trailingPadding)
            WeekdayHeaderView(weekStartDay: weekStartDay)
            CalendarScrollView(
                scrollPosition: $scrollPosition,
                weeks: model.weeks,
                focusedMonthID: visibleMonth.id,
                showLunarCalendar: store.calendar.showLunarCalendar,
                showSolarTerms: store.calendar.showSolarTerms,
                selectedDayID: selectedDay.id,
                onSelectDay: { selectedDay = $0 }
            )
            Divider()
                .padding(.trailing, CalendarGridLayout.trailingPadding)
            SelectedDayDetailView(day: selectedDay)
                .padding(.trailing, CalendarGridLayout.trailingPadding)
        }
        .padding(.top, 16)
        .padding(.leading, 16)
        .padding(.bottom, 16)
        .padding(.trailing, 8)
        .frame(width: 320)
        .background(.regularMaterial)
        .onAppear(perform: resetToCurrentMonth)
    }
}
