import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isDragging: Bool

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "film.stack")
                .font(.system(size: 80))
                .foregroundColor(.secondary)

            VStack(spacing: 10) {
                Text("Welcome to Claquette")
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                Text("Drop a video file here or use the buttons below")
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 20) {
//                Button(action: {
//                //    appState.openFile()
//                }) {
//                    Label("Open Video", systemImage: "folder")
//                        .frame(width: 140)
//                }
//                .buttonStyle(.borderedProminent)
//                .controlSize(.large)

                Button(action: { appState.showRecordingSheet = true }) {
                    Label("Record Screen", systemImage: "record.circle")
                        .frame(width: 140)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }

//            VStack(spacing: 8) {
//                Text("Supported formats")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                Text("MP4, MOV, M4V, GIF, WebM, AVI, MKV")
//                    .font(.caption2)
//                    .foregroundColor(.tertiaryLabel)
//            }
//            .padding(.top, 20)
        }
        .padding(60)
//        .background {
//            RoundedRectangle(cornerRadius: 20)
//                .strokeBorder(
//                    isDragging ? Color.accentColor : Color.clear,
//                    style: StrokeStyle(lineWidth: 3, dash: [10])
//                )
//                .background(
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
//                )
//        }
      //  .animation(.easeInOut(duration: 0.2), value: isDragging)
    }
}
