import SwiftUI

struct PresetButton: View {
    let title: String
    let size: String

    var body: some View {
        Button(action: {}) {
            HStack {
                Text(title)
                Spacer()
                Text(size)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
