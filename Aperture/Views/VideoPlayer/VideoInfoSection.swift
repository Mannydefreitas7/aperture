import SwiftUI
import AVFoundation

struct VideoInfoSection: View {
    let url: URL
    @State private var fileSize: String = "--"
    @State private var duration: String = "--"
    @State private var resolution: String = "--"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Video Info")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Duration", value: duration)
                InfoRow(label: "Resolution", value: resolution)
                InfoRow(label: "Size", value: fileSize)
                InfoRow(label: "Format", value: url.pathExtension.uppercased())
            }
        }
        .onAppear {
            loadVideoInfo()
        }
    }

    private func loadVideoInfo() {
        // File size
        if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
           let size = attrs[.size] as? Int64 {
            fileSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
        }

        // Video properties
        let asset = AVAsset(url: url)
        Task {
            if let track = try? await asset.loadTracks(withMediaType: .video).first {
                let size = try? await track.load(.naturalSize)
                let transform = try? await track.load(.preferredTransform)
                if let size = size, let transform = transform {
                    let correctedSize = size.applying(transform)
                    await MainActor.run {
                        resolution = "\(Int(abs(correctedSize.width))) × \(Int(abs(correctedSize.height)))"
                    }
                }
            }

            let dur = try? await asset.load(.duration)
            if let dur = dur {
                let seconds = CMTimeGetSeconds(dur)
                await MainActor.run {
                    duration = formatDuration(seconds)
                }
            }
        }
    }

    private func formatDuration(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
