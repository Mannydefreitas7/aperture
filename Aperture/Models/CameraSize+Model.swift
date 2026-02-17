import Foundation
import CoreGraphics

enum CameraSize: String, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"

    var dimensions: CGSize {
        switch self {
        case .small: return CGSize(width: 120, height: 90)
        case .medium: return CGSize(width: 200, height: 150)
        case .large: return CGSize(width: 320, height: 240)
        }
    }
}
