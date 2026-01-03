import Foundation
import CoreGraphics

struct ClickEvent: Identifiable {
    let id = UUID()
    let location: CGPoint
    let timestamp: Date
    let isRightClick: Bool
    var phase: ClickPhase = .started
}

enum ClickPhase {
    case started
    case ended
}
