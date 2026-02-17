//
//  CaptureEngine+ScreenCapture+Usage.swift
//  VideoEdit
//
//  Created by Emmanuel on 1/24/26.
//
//  Usage examples for the CaptureEngine screen capture and recording extensions

#if os(macOS)
import SwiftUI
import ScreenCaptureKit

// MARK: - Usage Examples

/*
 
 ## Example 1: Check and Request Permission
 
 ```swift
 let engine = CaptureEngine()
 
 // Check if permission is granted
 let hasPermission = await engine.checkScreenRecordingPermission()
 
 if !hasPermission {
     // Request permission
     let granted = try await engine.requestScreenRecordingPermission()
     
     if !granted {
         // Open System Preferences
         await engine.openScreenRecordingSettings()
     }
 }
 ```
 
 ## Example 2: Get Available Content
 
 ```swift
 // Get all available displays, windows, and applications
 let content = try await engine.getAvailableScreenCaptureContent()
 
 // Get filtered windows (on-screen, reasonable size)
 let windows = content.filteredWindows
 
 // Get all displays
 let displays = content.displays
 
 // Get external cameras
 let externalCameras = await engine.getAvailableExternalCameras()
 ```
 
 ## Example 3: Start Screen Capture (Display)
 
 ```swift
 // Get available content
 let content = try await engine.getAvailableScreenCaptureContent()
 
 guard let mainDisplay = content.displays.first else { return }
 
 // Configure capture
 let config = ScreenCaptureConfiguration(
     source: .display(mainDisplay),
     frameRate: 30,
     showsCursor: true,
     capturesAudio: true,
     scaleFactor: 1.0
 )
 
 // Start capturing
 try await engine.startScreenCapture(with: config)
 
 // Get sample buffer stream
 let sampleStream = engine.makeScreenCaptureSampleBufferStream()
 
 // Process samples
 for await sampleBuffer in sampleStream {
     // Process each frame...
 }
 
 // Stop when done
 try await engine.stopScreenCapture()
 ```
 
 ## Example 4: Start Window Capture
 
 ```swift
 let content = try await engine.getAvailableScreenCaptureContent()
 
 // Find a specific window (e.g., by title)
 guard let targetWindow = content.filteredWindows.first(where: { 
     $0.title?.contains("Safari") == true 
 }) else { return }
 
 let config = ScreenCaptureConfiguration(
     source: .window(targetWindow),
     frameRate: 60,
     showsCursor: false,
     capturesAudio: false,
     scaleFactor: 2.0  // Capture at 2x resolution
 )
 
 try await engine.startScreenCapture(with: config)
 ```
 
 ## Example 5: Start External Camera Capture
 
 ```swift
 let externalCameras = await engine.getAvailableExternalCameras()
 
 guard let camera = externalCameras.first else { return }
 
 let config = ScreenCaptureConfiguration(
     source: .externalCamera(camera),
     width: 1920,
     height: 1080,
     frameRate: 30
 )
 
 try await engine.startScreenCapture(with: config)
 ```
 
 ## Example 6: Start Screen Recording (to file)
 
 ```swift
 // Configure capture
 let captureConfig = ScreenCaptureConfiguration(
     source: .display(mainDisplay),
     frameRate: 30,
     showsCursor: true,
     capturesAudio: true
 )
 
 // Configure recording settings
 let recordingSettings = ScreenRecordingSettings(
     videoCodec: .h264,
     audioBitRate: 128_000,
     videoBitRate: 10_000_000,
     includeSystemAudio: true,
     includeMicrophoneAudio: false
 )
 
 // Start recording
 let outputURL = try await engine.startScreenRecording(
     captureConfig: captureConfig,
     recordingSettings: recordingSettings
 )
 
 print("Recording to: \(outputURL)")
 
 // ... record for some time ...
 
 // Stop recording
 let recording = try await engine.stopScreenRecording()
 print("Recording saved to: \(recording.url)")
 print("Duration: \(recording.duration) seconds")
 ```
 
 ## Example 7: Pause and Resume Recording
 
 ```swift
 // Start recording
 try await engine.startScreenRecording(captureConfig: config)
 
 // Pause after some time
 await engine.pauseScreenRecording()
 
 // Resume later
 await engine.resumeScreenRecording()
 
 // Check duration
 let duration = await engine.screenRecordingDuration
 print("Current duration: \(duration) seconds")
 
 // Stop
 let recording = try await engine.stopScreenRecording()
 ```
 
 ## Example 8: Complete SwiftUI Integration
 
 ```swift
 @MainActor
 class ScreenRecordingViewModel: ObservableObject {
     @Published var isRecording = false
     @Published var hasPermission = false
     @Published var displays: [SCDisplay] = []
     @Published var windows: [SCWindow] = []
     @Published var duration: TimeInterval = 0
     
     private let engine = CaptureEngine()
     private var durationTask: Task<Void, Never>?
     
     func checkPermission() async {
         hasPermission = await engine.checkScreenRecordingPermission()
     }
     
     func requestPermission() async {
         do {
             hasPermission = try await engine.requestScreenRecordingPermission()
         } catch {
             print("Permission error: \(error)")
         }
     }
     
     func loadContent() async {
         do {
             let content = try await engine.getAvailableScreenCaptureContent()
             displays = content.displays
             windows = content.filteredWindows
         } catch {
             print("Failed to load content: \(error)")
         }
     }
     
     func startRecording(display: SCDisplay) async {
         let captureConfig = ScreenCaptureConfiguration(
             source: .display(display),
             frameRate: 30,
             showsCursor: true,
             capturesAudio: true
         )
         
         do {
             _ = try await engine.startScreenRecording(captureConfig: captureConfig)
             isRecording = true
             startDurationTimer()
         } catch {
             print("Failed to start recording: \(error)")
         }
     }
     
     func stopRecording() async {
         do {
             let recording = try await engine.stopScreenRecording()
             isRecording = false
             durationTask?.cancel()
             duration = 0
             
             print("Saved to: \(recording.url)")
         } catch {
             print("Failed to stop recording: \(error)")
         }
     }
     
     private func startDurationTimer() {
         durationTask = Task { [weak self] in
             while !Task.isCancelled {
                 try? await Task.sleep(for: .milliseconds(100))
                 await MainActor.run {
                     self?.duration = self?.engine.screenRecordingDuration ?? 0
                 }
             }
         }
     }
 }
 
 struct ScreenRecordingView: View {
     @StateObject private var viewModel = ScreenRecordingViewModel()
     @State private var selectedDisplay: SCDisplay?
     
     var body: some View {
         VStack(spacing: 20) {
             if !viewModel.hasPermission {
                 Button("Grant Permission") {
                     Task {
                         await viewModel.requestPermission()
                     }
                 }
             } else {
                 Picker("Display", selection: $selectedDisplay) {
                     ForEach(viewModel.displays, id: \.displayID) { display in
                         Text("Display \(display.displayID)")
                             .tag(display as SCDisplay?)
                     }
                 }
                 
                 if viewModel.isRecording {
                     Text("Recording: \(viewModel.duration, format: .number.precision(.fractionLength(1)))s")
                         .font(.headline)
                     
                     Button("Stop Recording") {
                         Task {
                             await viewModel.stopRecording()
                         }
                     }
                     .buttonStyle(.borderedProminent)
                 } else {
                     Button("Start Recording") {
                         Task {
                             if let display = selectedDisplay {
                                 await viewModel.startRecording(display: display)
                             }
                         }
                     }
                     .buttonStyle(.borderedProminent)
                     .disabled(selectedDisplay == nil)
                 }
             }
         }
         .padding()
         .task {
             await viewModel.checkPermission()
             await viewModel.loadContent()
             if let first = viewModel.displays.first {
                 selectedDisplay = first
             }
         }
     }
 }
 ```
 
 */

#endif
