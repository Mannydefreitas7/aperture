import SwiftUI

// MARK: - Color Extensions

extension Color {
    static let recordingRed = Color(red: 0.9, green: 0.2, blue: 0.2)
    static let pausedOrange = Color(red: 0.95, green: 0.6, blue: 0.1)
    static let successGreen = Color(red: 0.2, green: 0.8, blue: 0.4)

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


// MARK: - View Extensions

extension View {

    // Hides the window control buttons
    func hideWindowControls(close: Bool = true, minimize: Bool = true, zoom: Bool = true) -> some View {
        modifier(WindowControlsModifier(hideClose: close, hideMinimize: minimize, hideZoom: zoom))
    }

    // Hides the window control buttons
    func centerWindow() -> some View {
        modifier(WindowCenteredModifier())
    }

    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
