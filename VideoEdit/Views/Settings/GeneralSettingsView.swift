import SwiftUI

struct GeneralSettingsView: View {
    @Binding var showCountdown: Bool
    @Binding var countdownDuration: Int
    @Binding var saveLocation: String
    @Binding var showNotifications: Bool
    @Binding var soundEffects: Bool

    var body: some View {
        Form {
            Section("Recording Countdown") {
                Toggle("Show countdown before recording", isOn: $showCountdown)

                if showCountdown {
                    Picker("Countdown duration", selection: $countdownDuration) {
                        Text("3 seconds").tag(3)
                        Text("5 seconds").tag(5)
                        Text("10 seconds").tag(10)
                    }
                    .pickerStyle(.segmented)
                }
            }

            Section("Storage") {
                Picker("Default save location", selection: $saveLocation) {
                    Text("Movies").tag("Movies")
                    Text("Desktop").tag("Desktop")
                    Text("Downloads").tag("Downloads")
                    Text("Documents").tag("Documents")
                }
            }

            Section("Notifications") {
                Toggle("Show notifications", isOn: $showNotifications)
                Toggle("Play sound effects", isOn: $soundEffects)
            }
        }
        .formStyle(.grouped)
    }
}
