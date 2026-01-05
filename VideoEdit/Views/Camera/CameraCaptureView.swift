//
//  CameraCaptureView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-04.
//

import SwiftUI
import AVKit
import AVFoundation

struct CameraCaptureView: View {
    @StateObject private var model = CameraCaptureModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            CapturePreviewView(session: model.session)
                .ignoresSafeArea()

            HStack(spacing: 12) {
                Button {
                    model.toggleRunning()
                } label: {
                    Label(model.isRunning ? "Stop Session" : "Start Session", systemImage: model.isRunning ? "pause.circle" : "play.circle")
                }

                Spacer()

                Button {
                    model.toggleRecording()
                } label: {
                    Label(model.isRecording ? "Stop" : "Record", systemImage: model.isRecording ? "stop.circle.fill" : "record.circle")
                }
                .keyboardShortcut("r", modifiers: [])
                .disabled(!model.isRunning)
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
        }
        .task {
            await model.configureIfNeeded()
        }
        .alert("Camera Permission Needed", isPresented: $model.showPermissionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Enable Camera access in System Settings → Privacy & Security → Camera.")
        }
    }
}

/// Wraps AVKit's AVCaptureView for SwiftUI.
private struct CapturePreviewView: NSViewRepresentable {
    let session: AVCaptureSession

    func makeNSView(context: Context) -> AVCaptureView {
        let view = AVCaptureView(frame: .zero)
      //  view.session = session
        // Fill edge-to-edge; AVCaptureView uses an internal preview layer.
        view.videoGravity = .resizeAspectFill
        return view
    }

    func updateNSView(_ nsView: AVCaptureView, context: Context) {
        if nsView.session !== session {
          //  nsView.session = session
        }
        nsView.videoGravity = .resizeAspectFill
    }
}

@MainActor
final class CameraCaptureModel: NSObject, ObservableObject {
    let session = AVCaptureSession()

    @Published var isRunning = false
    @Published var isRecording = false
    @Published var showPermissionAlert = false

    private let sessionQueue = DispatchQueue(label: "camera.capture.session.queue")
    private var isConfigured = false

    private let movieOutput = AVCaptureMovieFileOutput()

    func configureIfNeeded() async {
        guard !isConfigured else { return }

        let granted = await requestCameraPermission()
        guard granted else {
            showPermissionAlert = true
            return
        }

        // Configure on a background queue (AVFoundation recommends avoiding main thread).
        await withCheckedContinuation { cont in
            sessionQueue.async {
                self.configureSession()
                cont.resume()
            }
        }

        isConfigured = true
        toggleRunning(true)
    }

    func toggleRunning(_ force: Bool? = nil) {
        let shouldRun = force ?? !isRunning
        sessionQueue.async {
            if shouldRun {
                if !self.session.isRunning {
                    self.session.startRunning()
                }
            } else {
                if self.session.isRunning {
                    self.session.stopRunning()
                }
            }
            DispatchQueue.main.async {
                self.isRunning = shouldRun
                if !shouldRun {
                    self.isRecording = false
                }
            }
        }
    }

    func toggleRecording() {
        sessionQueue.async {
            if self.movieOutput.isRecording {
                self.movieOutput.stopRecording()
                return
            }

            let url = self.makeOutputURL()
            self.movieOutput.startRecording(to: url, recordingDelegate: self)
            DispatchQueue.main.async {
                self.isRecording = true
            }
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        // Choose a reasonable default.
        if session.canSetSessionPreset(.high) {
            session.sessionPreset = .high
        }

        // Video input.
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) else {
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
        } catch {
            return
        }

        // Optional audio input for movie recording.
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            do {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if session.canAddInput(audioInput) {
                    session.addInput(audioInput)
                }
            } catch {
                // Audio is optional; ignore.
            }
        }

        // Movie file output.
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }

        // Stabilization if available.
//        if let conn = movieOutput.connection(with: .video), conn.isVideoStabilizationSupported {
//            conn.preferredVideoStabilizationMode = .auto
//        }
    }

    private func makeOutputURL() -> URL {
        let movies = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first
        let dir = (movies ?? FileManager.default.temporaryDirectory).appendingPathComponent("VideoEdit", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        let stamp = formatter.string(from: Date()).replacingOccurrences(of: ":", with: "-")

        return dir.appendingPathComponent("capture-\(stamp).mov")
    }

    private func requestCameraPermission() async -> Bool {
        // macOS uses the same API as iOS for Camera authorization.
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                return true
            case .notDetermined:
                return await AVCaptureDevice.requestAccess(for: .video)
            default:
                return false
        }
    }
}

extension CameraCaptureModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        DispatchQueue.main.async {
            self.isRecording = false
        }

        if let error {
            // In a real app, surface this to the user.
            print("Recording error:", error)
        } else {
            print("Saved recording to:", outputFileURL.path)
        }
    }
}

#Preview {
    CameraCaptureView()
}
