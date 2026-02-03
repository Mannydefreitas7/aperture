//
//  AVDevice+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//

extension AVDevice: Model {

    // Computed properties
    var shape: AnyShape { shape(for: self) }
    //
    var isExternal: Bool {
        guard let device else { return false }
        return !device.manufacturer.lowercased().contains("apple")
    }
    //
    var input: AVCaptureDeviceInput? {
        guard let device else { return nil }
        return try? AVCaptureDeviceInput(device: device)
    }

}
