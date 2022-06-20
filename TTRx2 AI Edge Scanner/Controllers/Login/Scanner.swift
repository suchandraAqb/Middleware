//
//  Scanner.swift
//  TTRx2 AI Edge Scanner
//
//  Created by sayak sarkar on 14/10/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import AVFoundation
import UIKit

public protocol ScannerDelegate{
    func didScanned(code: String)
}

class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var viewScanner: UIView!
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    public var delegate: ScannerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewScanner.roundTopCorners(cornerRadious: 40)
        self.setUpCaptureSession()
        self.setUpPrivewLayer()
        self.captureSession.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    private func setUpCaptureSession(){
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
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
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417,.code128,.dataMatrix,.upce,.interleaved2of5]
            
            
        } else {
            failed()
            return
        }
    }
    
    private func setUpPrivewLayer(){
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer.frame = self.viewScanner.layer.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        self.viewScanner.layer.addSublayer(self.previewLayer)
    }
    
    private func failed(){
        let ac = UIAlertController(title: "Scanning not supported".getLocalizedString(), message: "Your device does not support scanning a code from an item. Please use a device with a camera.".getLocalizedString(), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK".getLocalizedString(), style: .default))
        present(ac, animated: true)
        self.captureSession = nil
    }
    
    internal func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        self.captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        dismiss(animated: true)
    }

    private func found(code: String) {
        self.delegate?.didScanned(code: code)
        self.navigationController?.popViewController(animated: true)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
extension ScannerVC{
    
    @IBAction func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sessionAction(_ sender: UIButton){
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
            sender.isSelected = false
        }else{
            captureSession.stopRunning()
            sender.isSelected = true
        }
    }
    @IBAction func flashAction(_ sender: UIButton){
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                sender.isSelected = false
                device.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                do {
                    sender.isSelected = true
                    try device.setTorchModeOn(level: 1.0)
                } catch {
                    print(error)
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
}
extension String{
    public func getLocalizedString() -> String{
        return NSLocalizedString(self, comment: "")
    }
}
