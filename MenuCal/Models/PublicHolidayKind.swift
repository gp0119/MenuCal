import Foundation

enum PublicHolidayKind: String, Codable, Hashable, Sendable {
    case holiday
    case workday

    var displayName: String {
        switch self {
        case .holiday: "休息日"
        case .workday: "调休上班"
        }
    }
}
