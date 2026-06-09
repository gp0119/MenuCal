import CoreGraphics

enum CalendarGridLayout {
    static let dayCellHeight: CGFloat = 44
    static let rowCount = 6
    static let columnCount = 7

    static var gridHeight: CGFloat {
        dayCellHeight * CGFloat(rowCount)
    }
}
