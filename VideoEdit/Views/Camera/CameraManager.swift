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

actor VCDeviceCameraManager {


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


    func start(_ session: AVCaptureSession, with selectedCamera: CameraInfo?) async throws -> AVCaptureDeviceInput {
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

    func stop(_ session: AVCaptureSession) async -> Void {
        guard session.isRunning else { return }

        await MainActor.run {
            session.stopRunning()
        }
    }


}

@MainActor
public final class CameraPreviewViewModel: ObservableObject {
    @Published var session = AVCaptureSession()
    private var videoInput: AVCaptureDeviceInput?
    private let cameraManager = VCDeviceCameraManager()
    var cancellables: Set<AnyCancellable> = []

    @Published var isRunning = false
    @Published var availableCameras: [CameraInfo] = []
    @Published var selectedCamera: CameraInfo? =  nil
    @Published var isMirrored = true
    @Published var isConnected: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentSession: AVCaptureSession? = nil

    init() {

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


    func loadcameras() async {
        availableCameras = await cameraManager.loadAvailableCameras()
        print("Available Cameras: \(availableCameras)")
    }


    func startSession(_ device: CameraInfo? = nil) async {
        do {
            videoInput = try await cameraManager.start(session, with: device)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stopSession() async {
        videoInput = nil
        await cameraManager.stop(session)
    }


    func selectCamera(_ device: CameraInfo) async {
        selectedCamera = device
        guard let currentSession else { return }

        if currentSession.isRunning {
            await cameraManager.stop(session)
        }

        await startSession(device)

    }
}
