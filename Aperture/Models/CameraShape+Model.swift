import Foundation
import SwiftUI

enum CameraShape: String, CaseIterable {
    case circle = "Circle"
    case roundedSquare = "Rounded Square"
    case rectangle = "Rectangle"

    var shape: AnyShape {
           switch self {
           case .circle:
               AnyShape(Circle())
           case .roundedSquare:
               AnyShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
           case .rectangle:
               AnyShape(Rectangle())
           }
       }
}
