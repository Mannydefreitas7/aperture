import Foundation
import CoreGraphics

enum ExportPreset: String, CaseIterable {
    case original = "Original"
    case hd1080 = "1080p HD"
    case hd720 = "720p HD"
    case sd480 = "480p SD"
    case instagram = "Instagram"
    case twitter = "Twitter/X"
    case tiktok = "TikTok"
    case custom = "Custom"

    var size: CGSize? {
        switch self {
        case .original: return nil
        case .hd1080: return CGSize(width: 1920, height: 1080)
        case .hd720: return CGSize(width: 1280, height: 720)
        case .sd480: return CGSize(width: 854, height: 480)
        case .instagram: return CGSize(width: 1080, height: 1080)
        case .twitter: return CGSize(width: 1280, height: 720)
        case .tiktok: return CGSize(width: 1080, height: 1920)
        case .custom: return nil
        }
    }
}
