//
//  ImagePickerView.swift
//  VSip-iOS
//
//  Created by machnguyen_uit on 6/7/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    
  fileprivate  func getAllGallery(vc:UIViewController)  {
        self.allowsEditing = true;
        self.delegate = self;
        self.sourceType = .photoLibrary;
        
        vc.present(self, animated: true, completion: nil)
    }
    
  fileprivate func setCallback(_ callback:@escaping ImagePickerViewCallback) {
        self.callback = callback;
    }
}

extension ImagePickerView:UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print(info)
        if  let image = info[UIImagePickerControllerEditedImage] {
            picker.dismiss(animated: true) {
                self.callback?(true,image)
            }
        }
    }
}

