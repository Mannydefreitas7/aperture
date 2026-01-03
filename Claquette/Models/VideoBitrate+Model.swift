import Foundation

enum VideoBitrate: String, CaseIterable {
    case low = "Low (5 Mbps)"
    case medium = "Medium (10 Mbps)"
    case high = "High (20 Mbps)"
    case veryHigh = "Very High (50 Mbps)"

    var value: Int {
        switch self {
        case .low: return 5_000_000
        case .medium: return 10_000_000
        case .high: return 20_000_000
        case .veryHigh: return 50_000_000
        }
    }
}
