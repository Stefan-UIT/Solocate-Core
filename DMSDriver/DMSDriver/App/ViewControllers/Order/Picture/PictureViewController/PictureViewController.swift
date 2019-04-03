//
//  PictureViewController.swift
//  DMSDriver
//
//  Created by MrJ on 2/12/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit
import AVFoundation

typealias PictureViewControllerCallback = (Bool,Order?) -> Void

class PictureViewController: BaseViewController {
    
    // MARK: IBOutlet
    @IBOutlet weak var previewView: UIView!
    
    
    // MARK: Vriables
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var navigationService = DMSNavigationService()
    
    var callback:PictureViewControllerCallback?
    var order:Order?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.perform(#selector(setupCamera), with: nil, afterDelay: 0.01)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        App().statusBarView?.backgroundColor = AppColor.white
    }
    
    override func updateNavigationBar() {
        super.updateNavigationBar()
        App().statusBarView?.backgroundColor = AppColor.background
        navigationService.navigationItem = self.navigationItem
        navigationService.navigationBar = self.navigationController?.navigationBar
        navigationService.delegate = self
        navigationService.updateNavigationBar(.Menu,nil,AppColor.background)
    }
    
    
    // MARK: Function
    @objc private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession ?? AVCaptureSession())
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = previewView.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)


            // Get an instance of ACCapturePhotoOutput class
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true
            // Set the output on the capture session
            captureSession?.addOutput(capturePhotoOutput ?? AVCapturePhotoOutput())
        } catch {
            print(error)
        }
        captureSession?.startRunning()
    }
    
    func goToApprovePictureViewController(_ image: UIImage) {
        let viewController = ApprovePictureViewController()
        viewController.imageToApprove = image
        viewController.order = order
        viewController.callback = {[weak self](success,order) in
            if success == true {
                self?.callback?(true,order)
            }
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: Action
    @IBAction func takePictureButtonAction(_ sender: UIButton) {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        // Call capturePhoto method by passing our photo settings and a
        // delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {
        let viewController = SignatureViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func goBackButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - DMSNavigationServiceDelegate
extension PictureViewController:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        showSideMenu()
    }
}


extension PictureViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                 resolvedSettings: AVCaptureResolvedPhotoSettings,
                 bracketSettings: AVCaptureBracketedStillImageSettings?,
                 error: Error?) {
        // get captured image
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return
        }
        // Convert photo same buffer to a jpeg image data by using // AVCapturePhotoOutput
        guard let imageData =
            AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
                return
        }
        // Initialise a UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            let imgCrop = image.cropToBounds(width: previewView.bounds.width, height: previewView.bounds.height)
            // Save our captured image to photos album
            UIImageWriteToSavedPhotosAlbum(imgCrop, nil, nil, nil)
            goToApprovePictureViewController(imgCrop)
        }
    }
}


