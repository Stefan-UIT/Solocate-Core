//
//  ImagePickerView.swift
//  VSip-iOS
//
//  Created by machnguyen_uit on 6/7/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import Photos

typealias ImagePickerViewCallback = (_ success:Bool, _ data: Any) -> Void

class ImagePickerView: UIImagePickerController {
    
    fileprivate var callback:ImagePickerViewCallback?
    static var imagePickerView:ImagePickerView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func shared() -> ImagePickerView  {
        if imagePickerView == nil {
            imagePickerView = ImagePickerView()
        }
        
        return imagePickerView!
    }
    
    
    func showImageGallaryMultiPicker(atVC:UIViewController ,
                                    callback:@escaping ImagePickerViewCallback){
        
        setCallback(callback);
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
        
        let actionGallery = UIAlertAction(title: "Album Gallery".localized, style: .default) {[weak self] (action) in
           self?.getAllGallery(vc: atVC, isMultiplePick: true)
        }
        
        let actionCamera = UIAlertAction(title: "Take photo".localized, style: .default) {[weak self] (action) in
            self?.getCamera(vc:atVC )
        }
        
        let cancel = UIAlertAction(title: "cancel".localized, style: .cancel) { (action) in
            //
        }
        
        alert.addAction(actionGallery);
        alert.addAction(actionCamera);
        alert.addAction(cancel);
        
        
        atVC.present(alert, animated: true, completion: nil)
        
    }
    
    func showCameraOnly(atVC:UIViewController ,
                                     callback:@escaping ImagePickerViewCallback){
        
        setCallback(callback);
        self.getCamera(vc:atVC)
    }
    
    func showImageGallarySinglePick(atVC:UIViewController ,
                                    buttomItem:UIView? = nil,
                                    callback:@escaping ImagePickerViewCallback){
        
        setCallback(callback);
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
        
        let actionGallery = UIAlertAction(title: "Album Gallery", style: .default) {[weak self] (action) in
            self?.getAllGallery(vc: atVC)
        }
        
        let actionCamera = UIAlertAction(title: "Take photo", style: .default) { (action) in
         //
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            //
        }
        
        alert.addAction(actionGallery);
        alert.addAction(actionCamera);
        alert.addAction(cancel);
        
        if let popoverController = alert.popoverPresentationController {
            
            let frame = atVC.view.convert(buttomItem?.bounds ?? CGRect.zero, from: buttomItem)
            popoverController.sourceView = atVC.view
            popoverController.sourceRect = frame
        }
        
        atVC.present(alert, animated: true, completion: nil)

    }
    
    @available(iOS 11.0, *)
    fileprivate func showAlertImagePickerMulti()  {
        let alert = UIAlertController(style: .actionSheet)
        alert.addPhotoLibraryPicker(
            flow: .vertical,
            paging: false,
            selection: .multiple(action: { (assets) in
                self.callback?(true,assets)
            }))
        alert.addAction(title: "Cancel", style: .cancel)
        alert.show()
    }
    
    @available(iOS 11.0, *)
    fileprivate func showAlertImagePickerSignle()  {
        let alert = UIAlertController(style: .actionSheet)
        alert.addPhotoLibraryPicker(
            flow: .horizontal,
            paging: true,
            selection: .single(action: { (asset) in
                if let _asset = asset {
                    let image = self.getAssetThumbnail(asset: _asset,
                                                       size: ScreenSize.SCREEN_WIDTH)
                    self.callback?(true,image)
                }
            }))
        alert.addAction(title: "Cancel", style: .cancel)
        alert.show()
    }
    
    
    fileprivate  func getAllGallery(vc:UIViewController, isMultiplePick:Bool = false)  {
        
        if #available(iOS 11, *) {
            if isMultiplePick {
                self.showAlertImagePickerMulti()
            }else{
                self.showAlertImagePickerSignle()
            }
            
        }else{
            self.allowsEditing = true;
            self.delegate = self;
            self.sourceType = .photoLibrary;
            
            vc.present(self, animated: true, completion: nil)
        }
    }
    
    fileprivate  func getCamera(vc:UIViewController)  {
        if !Platform.isSimulator {
            self.sourceType = .camera
            self.allowsEditing = true
            self.delegate = self
            vc.present(self, animated: true, completion: nil)
        }else {
            print("Simulator is do not support!")
        }
    }
    
    fileprivate func setCallback(_ callback:@escaping ImagePickerViewCallback) {
        self.callback = callback;
    }
    
    func getAssetThumbnail(asset: PHAsset, size: CGFloat) -> UIImage {
        let retinaScale = UIScreen.main.scale
        let retinaSquare = CGSize(width: size * retinaScale, height: size * retinaScale)
            
        let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
        let square = CGRect(x: 0, y: 0, width: CGFloat(cropSizeLength), height:  CGFloat(cropSizeLength))
            
        let cropRect = square.applying(CGAffineTransform(scaleX: 1.0/CGFloat(asset.pixelWidth), y: 1.0/CGFloat(asset.pixelHeight)))
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        var thumbnail = UIImage()
        
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.normalizedCropRect = cropRect
        
        manager.requestImage(for: asset, targetSize: retinaSquare, contentMode: .aspectFit, options: options, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
}

extension ImagePickerView:UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print(info)
        if  let image = info[UIImagePickerControllerEditedImage]{
            picker.dismiss(animated: true) {
                self.callback?(true,image)
            }
        }
    }
}

