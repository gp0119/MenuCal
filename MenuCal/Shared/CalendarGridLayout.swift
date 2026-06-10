import CoreGraphics

enum CalendarGridLayout {
    static let dayCellSize: CGFloat = 44
    static let dayContentSize: CGFloat = 38
    static let rowCount = 6
    static let columnCount = 7
    static let weekNumberColumnWidth: CGFloat = 24
    static let menuLeadingPadding: CGFloat = 16
    static let menuTrailingPadding: CGFloat = 8
    static let trailingPadding: CGFloat = 8

    static var gridHeight: CGFloat {
        dayCellSize * CGFloat(rowCount)
    }

    static func windowWidth(showWeekNumbers: Bool) -> CGFloat {
        dayCellSize * CGFloat(columnCount)
            + (showWeekNumbers ? weekNumberColumnWidth : 0)
            + menuLeadingPadding
            + menuTrailingPadding
            + trailingPadding
    }
}
