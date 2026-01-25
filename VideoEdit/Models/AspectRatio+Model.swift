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

enum AspectPreset: String, CaseIterable, Identifiable {
    /// Locks the hosting NSWindow to a fixed content aspect ratio while still allowing resize.
    case youtube
    case tiktok
    case instagram

    var id: String { rawValue }

    var ratio: CGSize {
        switch self {
            case .youtube:
                // Standard YouTube landscape
                return CGSize(width: 16, height: 9)
            case .tiktok:
                // Vertical video
                return CGSize(width: 9, height: 16)
            case .instagram:
                // Feed-safe default (4:5)
                return CGSize(width: 3, height: 4)
        }
    }

    var icon: String {
        switch self {
            case .youtube:
                return "rectangle.ratio.16.to.9"
            case .tiktok:
                return "rectangle.ratio.9.to.16"
            case .instagram:
                return "rectangle.ratio.3.to.4"
        }
    }

    /// Platform UI overlays to avoid (fractions of the target rect size).
    /// Values are approximate guides (not exact platform specs).
    var platformAvoidance: PlatformAvoidance? {
        switch self {
            case .tiktok:
                // TikTok commonly has UI at the top and a heavier stack at the bottom.
                return PlatformAvoidance(top: 0.12, bottom: 0.20, left: 0.0, right: 0.0)
            case .instagram:
                // Instagram feed/reels overlays tend to be lighter than TikTok.
                return PlatformAvoidance(top: 0.10, bottom: 0.14, left: 0.0, right: 0.0)
            default:
                return nil
        }
    }

    struct PlatformAvoidance: Equatable {
        var top: CGFloat
        var bottom: CGFloat
        var left: CGFloat
        var right: CGFloat
    }
}
