import SwiftUI
import AVFoundation
import Combine
import CombineAsync


struct CameraInfo: Identifiable, Hashable {
    let id: String
    let name: String
    let position: AVCaptureDevice.Position
    let deviceType: AVCaptureDevice.DeviceType
    let device: AVCaptureDevice
}

actor VCCameraSession {

    private let session = AVCaptureSession()

    @MainActor var current: AVCaptureSession {
        get async {
            await session.self
        }
    }

    func loadAvailableCameras() -> [CameraInfo] {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )

        return discoverySession.devices.map { device in
                CameraInfo(
                    id: device.uniqueID,
                    name: device.localizedName,
                    position: device.position,
                    deviceType: device.deviceType,
                    device: device
                )
            }
    }


    func startSession(with selectedCamera: CameraInfo?) async throws -> AVCaptureDeviceInput {
        guard !session.isRunning else {
            throw NSError(domain: String(describing: self), code: AVError.sessionNotRunning.rawValue)
        }

        session.beginConfiguration()
        session.sessionPreset = .high

        // Remove existing inputs
        for input in session.inputs {
            session.removeInput(input)
        }

        // Add video input
        guard let camera = selectedCamera, let input = try? AVCaptureDeviceInput(device: camera.device), session.canAddInput(input) else {
            session.commitConfiguration()
            throw NSError(domain: String(describing: self), code: AVError.sessionNotRunning.rawValue)
        }

        session.addInput(input)
        await MainActor.run {
            session.startRunning()
        }
        return input
    }

    func stopSession() async -> Void {
        guard session.isRunning else { return }

        await MainActor.run {
            session.stopRunning()
        }
    }


}

public final class CameraManager: ObservableObject {
    @Published var session = VCCameraSession()
    private var videoInput: AVCaptureDeviceInput?
    var cancellables: Set<AnyCancellable> = []

    @Published var isRunning = false
    @Published var availableCameras: [CameraInfo] = []
    @Published var selectedCamera: CameraInfo? =  nil
    @Published var isMirrored = true
    @Published var isConnected: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentSession: AVCaptureSession? = nil

    init() {

        $session
            .asyncMap { await $0.current }
            .assign(to: \.currentSession, on: self)
            .store(in: &cancellables)

        $currentSession
            .compactMap { $0 }
            .map { $0.isRunning }
            .assign(to: \.isRunning, on: self)
            .store(in: &cancellables)


        $availableCameras
            .map { cameras in
                cameras.first {
                   $0.device.isConnected
               }
            }
            .assign(to: \.selectedCamera, on: self)
            .store(in: &cancellables)

        $selectedCamera
            .compactMap { $0?.device }
            .map { $0.isConnected  }
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)

    }


    func startSession(_ device: CameraInfo? = nil) async {
        do {
            videoInput = try await session.startSession(with: device)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stopSession() async {
        videoInput = nil
         await session.stopSession()
    }


    func selectCamera(_ device: CameraInfo) async {
        selectedCamera = device
        guard let currentSession else { return }

        if currentSession.isRunning {
            await session.stopSession()
        }

        await startSession(device)

    }
}
