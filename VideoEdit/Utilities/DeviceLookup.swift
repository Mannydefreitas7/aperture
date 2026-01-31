/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An object that retrieves camera and microphone devices.
*/

import AVFoundation
import Combine

/// An object that retrieves camera and microphone devices.
final class DeviceLookup {
    
    // Discovery sessions to find the front and back cameras, and external cameras in iPadOS.
    private let frontCameraDiscoverySession: AVCaptureDevice.DiscoverySession
    private let backCameraDiscoverySession: AVCaptureDevice.DiscoverySession
    private let externalCameraDiscoverSession: AVCaptureDevice.DiscoverySession
    private let audioDiscoverySession: AVCaptureDevice.DiscoverySession

    static let shared = DeviceLookup()

    init() {

        backCameraDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [
                .builtInWideAngleCamera
        ],
                                                                      mediaType: .video,
                                                                      position: .back)
        frontCameraDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [
           // .builtInTrueDepthCamera,
                .builtInWideAngleCamera],
                                                                       mediaType: .video,
                                                                       position: .front)
        externalCameraDiscoverSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.external],
                                                                         mediaType: .video,
                                                                         position: .unspecified)

        audioDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.microphone],
                                                                 mediaType: .audio,
                                                                 position: .unspecified)

        // If the host doesn't currently define a system-preferred camera device, set the user's preferred selection to the back camera.
        if AVCaptureDevice.systemPreferredCamera == nil {
            AVCaptureDevice.userPreferredCamera = backCameraDiscoverySession.devices.first
        }
    }
    
    /// Returns the system-preferred camera for the host system.
    static var defaultCamera: AVCaptureDevice? {
        AVCaptureDevice.systemPreferredCamera
    }
    
    /// Returns the default microphone for the device on which the app runs.
   static var defaultMic: AVCaptureDevice? {
       AVCaptureDevice.default(for: .audio) 
    }

    var cameras: [AVCaptureDevice] {
        // Populate the cameras array with the available cameras.
        var cameras: [AVCaptureDevice] = []
        if let backCamera = backCameraDiscoverySession.devices.first {
            cameras.append(backCamera)
        }
        if let frontCamera = frontCameraDiscoverySession.devices.first {
            cameras.append(frontCamera)
        }
        // iPadOS supports connecting external cameras.
        if let externalCamera = externalCameraDiscoverSession.devices.first {
            cameras.append(externalCamera)
        }

#if !targetEnvironment(simulator)
        if cameras.isEmpty {
            fatalError("No camera devices are found on this system.")
        }
#endif
        return cameras
    }


    var microphones : [AVCaptureDevice] {
        let devices = audioDiscoverySession.devices
        logger.info("devices \(devices)")
        return devices
    }
}
