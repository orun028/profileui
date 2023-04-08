//
//  CameraView.swift
//  profileui
//
//  Created by Admin on 06/04/2023.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @State private var isShowingScanner = false
    @State private var scannedCode = ""
    
    var body: some View {
        VStack {
            Text("Scanned QR Code: \(scannedCode)")
                .padding()
            
            Button(action: {
                self.isShowingScanner = true
            }) {
                Text("Scan QR Code")
            }
        }
        .sheet(isPresented: $isShowingScanner, onDismiss: {
            // Handle what happens when the scanner is dismissed (e.g. save the scanned code)
            self.saveScannedCode()
        }) {
            QRCodeScanner(scannedCode: self.$scannedCode)
        }
    }
    
    func saveScannedCode() {
        // Do something with the scanned code (e.g. save it to a database)
        print("Save database code: \(scannedCode)")
    }
}

struct QRCodeScanner: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    
    func makeUIViewController(context: Context) -> QRCodeScannerViewController {
        let viewController = QRCodeScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: QRCodeScannerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scannedCode: $scannedCode)
    }
    
    class Coordinator: NSObject, QRCodeScannerViewControllerDelegate {
        @Binding var scannedCode: String
        
        init(scannedCode: Binding<String>) {
            _scannedCode = scannedCode
        }
        
        func didScanCode(_ code: String) {
            scannedCode = code
        }
    }
}

protocol QRCodeScannerViewControllerDelegate {
    func didScanCode(_ code: String)
}

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var delegate: QRCodeScannerViewControllerDelegate?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var borderLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        // Create a new shape layer for the border
        borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor.green.cgColor
        borderLayer.lineWidth = 2
        borderLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(borderLayer)

        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.borderColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        borderLayer.removeFromSuperlayer()

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)

            // Convert the metadata object's coordinates to the view's coordinate system
            let transformedMetadataObject = previewLayer.transformedMetadataObject(for: metadataObject)

            // Create a path for the border around the metadata object
            let borderPath = UIBezierPath(rect: transformedMetadataObject!.bounds)

            // Update the border layer's path to be the path created above
            borderLayer.path = borderPath.cgPath
        }

        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        delegate?.didScanCode(code)
        dismiss(animated: true)
    }
    
}

struct QRCodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
