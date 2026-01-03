import Foundation
import CoreGraphics

enum AspectRatio: String, CaseIterable {
    case free = "Free"
    case square = "1:1"
    case portrait = "9:16"
    case landscape = "16:9"
    case fourThree = "4:3"
    case threeTwo = "3:2"
    case instagram = "4:5"
    case custom = "Custom"

    var ratio: CGFloat? {
        switch self {
        case .free: return nil
        case .square: return 1.0
        case .portrait: return 9.0 / 16.0
        case .landscape: return 16.0 / 9.0
        case .fourThree: return 4.0 / 3.0
        case .threeTwo: return 3.0 / 2.0
        case .instagram: return 4.0 / 5.0
        case .custom: return nil
        }
    }
}
