import Combine
import Sparkle
import SwiftUI

@MainActor
private final class CalendarMenuModel: ObservableObject {
    private struct Data {
        let weeks: [CalendarWeek]
        let fallbackMonth: CalendarMonth
        let monthsByID: [String: CalendarMonth]
        let weekIndexByID: [String: Int]
        let firstDayWeekIDByMonthID: [String: String]
    }

    @Published private var data: Data

    var weeks: [CalendarWeek] { data.weeks }
    var today: CalendarDay { data.weeks.lazy.flatMap(\.days).first(where: \.isToday)! }
    var fallbackMonth: CalendarMonth { data.fallbackMonth }
    var monthsByID: [String: CalendarMonth] { data.monthsByID }
    var weekIndexByID: [String: Int] { data.weekIndexByID }
    var firstDayWeekIDByMonthID: [String: String] { data.firstDayWeekIDByMonthID }

    init(weekStartDay: WeekStartDay) {
        data = Self.makeData(around: .now, weekStartDay: weekStartDay)
    }

    func regenerate(around date: Date, weekStartDay: WeekStartDay) {
        data = Self.makeData(around: date, weekStartDay: weekStartDay)
    }

    private static func makeData(around date: Date, weekStartDay: WeekStartDay) -> Data {
        let generator = CalendarGenerator()
        let weeks = generator.weeks(around: date, weekStartDay: weekStartDay)

        var weekIndexByID: [String: Int] = [:]
        var firstDayWeekIDByMonthID: [String: String] = [:]
        for (index, week) in weeks.enumerated() {
            weekIndexByID[week.id] = index
            for day in week.days where day.day == 1 {
                firstDayWeekIDByMonthID[day.monthID] = week.id
            }
        }

        let months = generator.months(around: date)
        return Data(
            weeks: weeks,
            fallbackMonth: generator.month(containing: date) ?? months[months.count / 2],
            monthsByID: Dictionary(uniqueKeysWithValues: months.map { ($0.id, $0) }),
            weekIndexByID: weekIndexByID,
            firstDayWeekIDByMonthID: firstDayWeekIDByMonthID
        )
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

        var scrollPosition = ScrollPosition(idType: String.self)
        if
            let currentMonth = CalendarGenerator().month(containing: .now),
            let weekID = model.firstDayWeekIDByMonthID[currentMonth.id]
        {
            scrollPosition.scrollTo(id: weekID, anchor: .top)
        }
        _scrollPosition = State(initialValue: scrollPosition)
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

    private func regenerateAndScrollToMonth(year: Int, month: Int) {
        guard
            let date = Calendar.current.date(
                from: DateComponents(year: year, month: month, day: 1))
        else {
            return
        }

        model.regenerate(around: date, weekStartDay: weekStartDay)
        Task { @MainActor in
            await Task.yield()
            scrollToLoadedMonth(year: year, month: month)
        }
    }

    private func scrollToLoadedMonth(year: Int, month: Int) {
        let monthID = String(format: "%04d-%02d", year, month)
        guard let weekID = model.firstDayWeekIDByMonthID[monthID] else { return }
        scrollPosition.scrollTo(id: weekID, anchor: .top)
    }

    private func resetToCurrentMonth() {
        let now = Date.now
        let components = Calendar.current.dateComponents([.year, .month], from: now)
        guard let year = components.year, let month = components.month else { return }

        model.regenerate(around: now, weekStartDay: weekStartDay)
        selectedDay = model.today
        Task { @MainActor in
            await Task.yield()
            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                scrollToLoadedMonth(year: year, month: month)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CalendarHeaderView(
                month: visibleMonth,
                onGoToToday: resetToCurrentMonth,
                onSelectMonth: regenerateAndScrollToMonth,
                updater: updater
            )
            .padding(.trailing, CalendarGridLayout.trailingPadding)
            WeekdayHeaderView(
                weekStartDay: weekStartDay,
                showWeekNumbers: store.showsWeekNumbers
            )
            CalendarScrollView(
                scrollPosition: $scrollPosition,
                weeks: model.weeks,
                focusedMonthID: visibleMonth.id,
                showLunarCalendar: store.calendar.showLunarCalendar,
                showSolarTerms: store.calendar.showSolarTerms,
                showPublicHolidays: store.calendar.showPublicHolidays,
                showWeekNumbers: store.showsWeekNumbers,
                selectedDayID: selectedDay.id,
                onSelectDay: { selectedDay = $0 }
            )
            Divider()
                .padding(.trailing, CalendarGridLayout.trailingPadding)
            SelectedDayDetailView(
                day: selectedDay,
                showPublicHolidays: store.calendar.showPublicHolidays
            )
                .padding(.trailing, CalendarGridLayout.trailingPadding)
        }
        .padding(.top, 16)
        .padding(.leading, CalendarGridLayout.menuLeadingPadding)
        .padding(.bottom, 16)
        .padding(.trailing, CalendarGridLayout.menuTrailingPadding)
        .frame(width: CalendarGridLayout.windowWidth(showWeekNumbers: store.showsWeekNumbers))
        .background(.regularMaterial)
        .onDisappear {
            if !store.remembersLastDisplayedDate {
                resetToCurrentMonth()
            }
        }
    }
}
