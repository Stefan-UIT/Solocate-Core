//
//  ScanBarCodeViewController.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 3/22/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import AVFoundation

class ScanBarCodeViewController: UIViewController {
    fileprivate var captureSession: AVCaptureSession!
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    var didScan:((_ code: String) -> Void)?
  
    @IBOutlet weak var scanerContainerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
        }catch let error {
          print("init input device fails \(error.localizedDescription)")
          return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
            
        }else {
          failed()
          return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
          captureSession.addOutput(metadataOutput)
          metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
          metadataOutput.metadataObjectTypes = [.code128,
                                                .code93,
                                                .code39,
                                                .ean8,
                                                .ean13,
                                                .upce,
                                                .itf14,
                                                .interleaved2of5,
                                                .aztec,
                                                .code39Mod43,
                                                .dataMatrix,
                                                .qr,
                                                .pdf417]
        }else {
          failed()
          return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        scanerContainerView.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
  
    @IBAction func closeScanner(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
  
    private func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
  
    private func found(code: String) {
        didScan?(code)
    }
  
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension ScanBarCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
          guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
          guard let stringValue = readableObject.stringValue else { return }
          AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
          print("-------------")
          print(stringValue)
          dismiss(animated: true, completion: {
            self.found(code: stringValue)
          })
        }
    }
}
