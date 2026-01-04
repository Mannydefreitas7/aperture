import SwiftUI
import AVFoundation

struct PlaybackControls: View {
    @ObservedObject var playerManager: VideoPlayerManager

    var body: some View {
        HStack(spacing: 20) {
            // Time display
            Text(formatTime(playerManager.currentTime))
                .font(.caption.monospacedDigit())
                .foregroundColor(.secondary)
                .frame(width: 70, alignment: .leading)

            // Step backward
            Button(action: { playerManager.stepBackward() }) {
                Image(systemName: "backward.frame.fill")
                    .font(.title3)
            }
            .buttonStyle(.plain)

            // Play/Pause
            Button(action: { playerManager.togglePlayPause() }) {
                Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.space, modifiers: [])

            // Step forward
            Button(action: { playerManager.stepForward() }) {
                Image(systemName: "forward.frame.fill")
                    .font(.title3)
            }
            .buttonStyle(.plain)

            // Progress slider
            Slider(
                value: Binding(
                    get: { playerManager.currentTime },
                    set: { playerManager.seek(to: $0) }
                ),
                in: 0...max(playerManager.duration, 0.1)
            )
            .frame(minWidth: 200)

            // Duration display
            Text(formatTime(playerManager.duration))
                .font(.caption.monospacedDigit())
                .foregroundColor(.secondary)
                .frame(width: 70, alignment: .trailing)

            // Volume
            Image(systemName: "speaker.wave.2.fill")
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let frames = Int((time.truncatingRemainder(dividingBy: 1)) * 30)
        return String(format: "%02d:%02d:%02d", minutes, seconds, frames)
    }
}
