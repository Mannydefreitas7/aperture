import Foundation
import CoreGraphics

enum ExportResolution: String, CaseIterable {
    case original = "Original"
    case r2160p = "4K (2160p)"
    case r1080p = "1080p"
    case r720p = "720p"
    case r480p = "480p"
    case custom = "Custom"

    var size: CGSize? {
        switch self {
        case .original: return nil
        case .r2160p: return CGSize(width: 3840, height: 2160)
        case .r1080p: return CGSize(width: 1920, height: 1080)
        case .r720p: return CGSize(width: 1280, height: 720)
        case .r480p: return CGSize(width: 854, height: 480)
        case .custom: return nil
        }
    }
}
