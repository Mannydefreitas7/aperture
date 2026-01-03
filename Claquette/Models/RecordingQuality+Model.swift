import Foundation
import CoreGraphics

enum RecordingQuality: String, CaseIterable {
    case high = "High"
    case performance = "Performance"
    case balanced = "Balanced"
    case quality = "Quality"

    var scaleFactor: CGFloat {
        switch self {
        case .performance: return 0.5
        case .balanced: return 0.75
        case .quality, .high: return 1.0
        }
    }

    var frameRate: Int {
        switch self {
        case .performance: return 30
        case .balanced, .high: return 60
        case .quality: return 60
        }
    }
}
