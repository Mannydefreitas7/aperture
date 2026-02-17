import SwiftUI

struct ExportSettingsView: View {
    @Binding var defaultGifFrameRate: Int
    @Binding var autoOptimizeGifs: Bool

    var body: some View {
        Form {
            Section("GIF Defaults") {
                Picker("Default frame rate", selection: $defaultGifFrameRate) {
                    Text("10 fps").tag(10)
                    Text("15 fps").tag(15)
                    Text("20 fps").tag(20)
                    Text("24 fps").tag(24)
                    Text("30 fps").tag(30)
                }
                .pickerStyle(.segmented)

                Toggle("Auto-optimize GIFs", isOn: $autoOptimizeGifs)

                Text("Higher frame rates produce smoother GIFs but larger file sizes.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("Video Export") {
                Text("Default video codec: H.264")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Videos are exported at the original resolution and frame rate unless specified otherwise.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("Optimization") {
                Text("When optimization is enabled, GIFs will be processed to reduce file size while maintaining quality.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
