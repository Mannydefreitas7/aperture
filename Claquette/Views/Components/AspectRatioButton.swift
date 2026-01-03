import SwiftUI

struct AspectRatioButton: View {
    let ratio: AspectRatio
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Visual representation
                RoundedRectangle(cornerRadius: 2)
                    .stroke(isSelected ? Color.accentColor : Color.secondary, lineWidth: 1)
                    .frame(width: aspectWidth, height: aspectHeight)

                Text(ratio.rawValue)
                    .font(.caption2)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private var aspectWidth: CGFloat {
        switch ratio {
        case .square: return 24
        case .portrait: return 18
        case .landscape: return 32
        case .fourThree: return 28
        case .threeTwo: return 30
        case .instagram: return 22
        default: return 28
        }
    }

    private var aspectHeight: CGFloat {
        switch ratio {
        case .square: return 24
        case .portrait: return 32
        case .landscape: return 18
        case .fourThree: return 21
        case .threeTwo: return 20
        case .instagram: return 27
        default: return 18
        }
    }
}
