import Foundation

/// 查表返回国务院公布的法定放假日与调休上班日。
/// 数据来自打包的 `PublicHolidays.json`（2024–2026，来源 holiday-cn / 国务院办公厅通知）。
struct HolidayCalendarService {
    static let shared = HolidayCalendarService()

    private let gregorian = Calendar(identifier: .gregorian)
    private let lookup: [String: PublicHolidayKind]

    init() {
        lookup = Self.loadLookup()
    }

    func kind(for date: Date) -> PublicHolidayKind? {
        let components = gregorian.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year, let month = components.month, let day = components.day else {
            return nil
        }
        let key = String(format: "%04d%02d%02d", year, month, day)
        return lookup[key]
    }

    private static func loadLookup() -> [String: PublicHolidayKind] {
        guard
            let url = Bundle.main.url(forResource: "PublicHolidays", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let raw = try? JSONDecoder().decode([String: String].self, from: data)
        else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: raw.compactMap { key, value in
            PublicHolidayKind(rawValue: value).map { (key, $0) }
        })
    }
}
