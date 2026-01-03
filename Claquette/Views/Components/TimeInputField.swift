import SwiftUI

struct TimeInputField: View {
    @Binding var time: Double
    let maxTime: Double

    @State private var textValue: String = "00:00:00"
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("00:00:00", text: $textValue)
            .textFieldStyle(.roundedBorder)
            .frame(width: 80)
            .focused($isFocused)
            .onAppear {
                textValue = formatTime(time)
            }
            .onChange(of: time) { _, newValue in
                if !isFocused {
                    textValue = formatTime(newValue)
                }
            }
            .onSubmit {
                if let parsedTime = parseTime(textValue) {
                    time = min(parsedTime, maxTime)
                    textValue = formatTime(time)
                }
            }
            .onChange(of: isFocused) { _, focused in
                if !focused {
                    // Validate and format when losing focus
                    if let parsedTime = parseTime(textValue) {
                        time = min(parsedTime, maxTime)
                    }
                    textValue = formatTime(time)
                }
            }
    }

    private func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }

    private func parseTime(_ string: String) -> Double? {
        let components = string.split(separator: ":").compactMap { Int($0) }
        guard components.count == 3 else { return nil }
        return Double(components[0] * 3600 + components[1] * 60 + components[2])
    }
}
