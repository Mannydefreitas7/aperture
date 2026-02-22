import SwiftUI
import AVFoundation
import Combine

extension Layer {
    static var placeholder: Self {
        .init(name: "Placeholder")
    }
    static var video: Self {
        .init(name: "Video")
    }
}