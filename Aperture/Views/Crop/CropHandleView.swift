import SwiftUI

struct CropHandleView: View {
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 16, height: 16)
            .overlay(
                Circle()
                    .stroke(Color.accentColor, lineWidth: 2)
            )
            .shadow(radius: 2)
    }
}
