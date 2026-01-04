import SwiftUI

struct RecordingSettingsView: View {
    @Binding var defaultRecordingQuality: String

    var body: some View {
        Form {
            Section("Quality") {
                Picker("Default recording quality", selection: $defaultRecordingQuality) {
                    Text("Performance (Lower quality, smaller files)").tag("Performance")
                    Text("Balanced").tag("Balanced")
                    Text("Quality (Best quality, larger files)").tag("Quality")
                }
                .pickerStyle(.radioGroup)
            }

            Section("Frame Rate") {
                Text("Recording at higher frame rates produces smoother videos but larger file sizes.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("Codec") {
                Text("H.264 codec is used for maximum compatibility.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
