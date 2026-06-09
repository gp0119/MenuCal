import Foundation

/// 把公历 `Date` 转成日历格子里显示的农历短文本。
///
/// 显示优先级：传统节日 > 节气 > 农历日期。
///
/// - 农历日期、传统节日：由 Foundation 的 `Calendar(identifier: .chinese)` 精确推算。
/// - 24 节气：Foundation 不提供，改用打包的天文真值表 `SolarTerms.json`（按年查表，
///   每年 24 个 `MMDD`，顺序为立春…大寒）。有效范围 1900–2100，超出范围不显示节气。
struct LunarDateFormatter {
    static let shared = LunarDateFormatter()

    private let chinese = Calendar(identifier: .chinese)
    private let gregorian = Calendar(identifier: .gregorian)

    func shortText(
        for date: Date,
        showLunarCalendar: Bool = true,
        showSolarTerms: Bool = true
    ) -> String {
        if showLunarCalendar, let festival = festival(for: date) { return festival }
        if showSolarTerms, let term = solarTerm(for: date) { return term }
        return showLunarCalendar ? lunarDay(for: date) : ""
    }

    /// 农历年的干支表示，例如 "乙巳年"。
    func lunarYear(for date: Date) -> String {
        let year = chinese.component(.year, from: date)
        guard year >= 1 else { return "" }
        let stem = Self.heavenlyStems[(year - 1) % 10]
        let branch = Self.earthlyBranches[(year - 1) % 12]
        return "\(stem)\(branch)年"
    }

    /// 完整农历日期，例如 "乙巳年 四月初八"。
    func lunarDate(for date: Date) -> String {
        let components = chinese.dateComponents([.month, .day, .isLeapMonth], from: date)
        guard
            let month = components.month,
            let day = components.day,
            (1...12).contains(month),
            (1...30).contains(day)
        else {
            return ""
        }

        let leapPrefix = components.isLeapMonth == true ? "闰" : ""
        let monthName = Self.lunarMonthNames[month - 1]
        let dayName = Self.lunarDayNames[day - 1]
        return "\(lunarYear(for: date)) \(leapPrefix)\(monthName)\(dayName)"
    }

    func festivalText(for date: Date) -> String? {
        festival(for: date)
    }

    func solarTermText(for date: Date) -> String? {
        solarTerm(for: date)
    }

    // MARK: - 农历日期

    /// 纯农历日文本（不含节日/节气替换），例如 "初八"、"正月"。
    func lunarDay(for date: Date) -> String {
        let components = chinese.dateComponents([.month, .day, .isLeapMonth], from: date)
        // Foundation's chinese calendar reports day == 0 for a few boundary dates
        // (e.g. 2057-09-28), so reject anything outside 1...30 to keep the lookups
        // below in range instead of crashing on a negative index.
        guard let month = components.month, let day = components.day, (1...30).contains(day) else {
            return ""
        }
        if day == 1 {
            let name = Self.lunarMonthNames[(month - 1) % 12]
            return components.isLeapMonth == true ? "闰" + name : name
        }
        return Self.lunarDayNames[(day - 1) % 30]
    }

    // MARK: - 节日

    private func festival(for date: Date) -> String? {
        let lunar = chinese.dateComponents([.month, .day, .isLeapMonth], from: date)
        if lunar.isLeapMonth != true, let month = lunar.month, let day = lunar.day {
            if month == 12, isLunarNewYearEve(date) {
                return "除夕"
            }
            if let festival = Self.lunarFestivals["\(month)-\(day)"] {
                return festival
            }
        }

        let solar = gregorian.dateComponents([.month, .day], from: date)
        if let month = solar.month, let day = solar.day,
           let festival = Self.solarFestivals["\(month)-\(day)"] {
            return festival
        }
        return nil
    }

    private func isLunarNewYearEve(_ date: Date) -> Bool {
        guard let next = gregorian.date(byAdding: .day, value: 1, to: date) else { return false }
        let components = chinese.dateComponents([.month, .day], from: next)
        return components.month == 1 && components.day == 1
    }

    // MARK: - 节气（查表）

    private func solarTerm(for date: Date) -> String? {
        let components = gregorian.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year, let month = components.month, let day = components.day,
              let terms = Self.solarTermTable[year]
        else {
            return nil
        }

        let key = String(format: "%02d%02d", month, day)
        guard let index = terms.firstIndex(of: key) else { return nil }
        return Self.solarTermNames[index]
    }
}

// MARK: - 静态数据

private extension LunarDateFormatter {
    static let lunarDayNames = [
        "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十",
    ]

    static let lunarMonthNames = [
        "正月", "二月", "三月", "四月", "五月", "六月",
        "七月", "八月", "九月", "十月", "冬月", "腊月",
    ]

    static let heavenlyStems = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]

    static let earthlyBranches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]

    static let lunarFestivals: [String: String] = [
        "1-1": "春节", "1-15": "元宵", "2-2": "龙头节",
        "5-5": "端午", "7-7": "七夕", "7-15": "中元",
        "8-15": "中秋", "9-9": "重阳", "12-8": "腊八", "12-23": "小年",
    ]

    static let solarFestivals: [String: String] = [
        "1-1": "元旦", "3-8": "妇女节", "5-1": "劳动节",
        "6-1": "儿童节", "9-10": "教师节", "10-1": "国庆",
    ]

    // 顺序与 SolarTerms.json 每年数组一致：立春、雨水、惊蛰…大寒。
    static let solarTermNames = [
        "立春", "雨水", "惊蛰", "春分", "清明", "谷雨", "立夏", "小满",
        "芒种", "夏至", "小暑", "大暑", "立秋", "处暑", "白露", "秋分",
        "寒露", "霜降", "立冬", "小雪", "大雪", "冬至", "小寒", "大寒",
    ]

    // 年份 -> 当年 24 节气的 "MMDD" 数组（来自打包的天文真值表）。
    static let solarTermTable: [Int: [String]] = {
        guard
            let url = Bundle.main.url(forResource: "SolarTerms", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let raw = try? JSONDecoder().decode([String: [String]].self, from: data)
        else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: raw.compactMap { key, value in
            Int(key).map { ($0, value) }
        })
    }()
}
