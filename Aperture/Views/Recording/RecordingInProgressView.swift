import SwiftUI

struct RecordingInProgressView: View {
    @ObservedObject var recorder: ScreenRecorder
    let stopAction: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Recording indicator
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 16, height: 16)
                    .opacity(recorder.isPaused ? 0.5 : 1.0)

                Text(recorder.isPaused ? "Paused" : "Recording")
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            // Duration
            Text(formatDuration(recorder.recordingDuration))
                .font(.system(size: 48, weight: .light, design: .monospaced))

            // Controls
            HStack(spacing: 24) {
                // Pause/Resume
                Button(action: {
                    if recorder.isPaused {
                        recorder.resumeRecording()
                    } else {
                        recorder.pauseRecording()
                    }
                }) {
                    Image(systemName: recorder.isPaused ? "play.fill" : "pause.fill")
                        .font(.title)
                        .frame(width: 60, height: 60)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                // Stop
                Button(action: stopAction) {
                    Image(systemName: "stop.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // Keyboard shortcut hint
            Text("Press ⌘⇧R to stop recording")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
