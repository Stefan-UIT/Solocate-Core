//
//  UIViewController.swift
//  truck4less
//
//  Created by phunguyen on 1/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import Foundation
import SVProgressHUD

extension UIViewController {
    
//    func showPalletReturnedPopUp(title:String, message:String, submitCompletionHandler:((_ action: UIAlertAction) -> Void)? = nil) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        
//        //2. Add the text field. You can configure it however you need.
//        alert.addTextField { (textField) in
//            textField.keyboardType = .numberPad
//            textField.text = ""
//        }
//        
//        // 3. Grab the value from the text field, and print it when the user clicks OK.
//        alert.addAction(UIAlertAction(title: "submit".localized, style: .default, handler: { [weak alert] (_) in
//
//        }))
//        
//        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: {
//            action in
//        }))
//        
//        // 4. Present the alert.
//        self.present(alert, animated: true, completion: nil)
//    }
    
   static func loadSB<T>(SB:SBName) -> T {
        return UIStoryboard(name: SB.rawValue,
                            bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: T.self)) as! T;
    }
    
   static func load<T: UIViewController>(nib: String? = nil) -> T {
        return T(nibName: nib != nil ? nib : String(describing: T.self),
                 bundle: nil);
    }
    
    func showAlertView(_ title:String? = nil, _ message: String? = nil,
                       positiveTitle: String? = nil,
                       positiveAction:((_ action: UIAlertAction) -> Void)? = nil,
                       negativeTitle: String? = nil,
                       negativeAction: ((_ action: UIAlertAction) -> Void)? = nil)  {
        let alert = UIAlertController(title: E(title), message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: isEmpty(positiveTitle) ? "OK".localized : positiveTitle, style: .default, handler: positiveAction)
        let cancelAction = UIAlertAction(title: isEmpty(negativeTitle) ? "Cancel".localized : negativeTitle, style: .cancel, handler: negativeAction)
            alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    func showAlertView(_ message: String, completionHandler:((_ action: UIAlertAction) -> Void)? = nil)  {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localized, style: .default, handler: completionHandler)
        alert.addAction(okAction)
    
        present(alert, animated: true, completion: nil)
    }
    
    func showImage(_ image: UIImage? = nil , linkUrl:String? = nil, placeHolder:UIImage? = nil) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        let imgView = UIImageView(frame: CGRect(origin: .zero, size: window.frame.size))
        imgView.isUserInteractionEnabled = true
        let button = UIButton(frame: CGRect(x: window.frame.size.width - 60.0, y: 40, width: 40, height: 40))
        button.setImage(UIImage(named: "close"), for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(self.dismissImageView(_:)), for: .touchUpInside)
        imgView.addSubview(button)
        imgView.contentMode = .scaleAspectFit
        imgView.backgroundColor = .black
        window.addSubview(imgView)
        imgView.tag = 1001
        
        if let _imv = image {
            imgView.image = _imv
        }
        
        if let link = linkUrl {
            imgView.setImage(withURL: link)
            //imgView.setImageWithURL(url:link,placeHolderImage: placeHolder)
        }
    }
  
  @objc private func dismissImageView(_ sender: UIButton) {
    if let window = UIApplication.shared.keyWindow,
      let imgView = window.viewWithTag(1001){
      imgView.removeFromSuperview()
    }
  }
    
  func showLoadingIndicator() {
    SVProgressHUD.show()
  }
  
  func dismissLoadingIndicator() {
    SVProgressHUD.dismiss()
  }
  
  func showSuccessufullIndicator() {
    SVProgressHUD.showSuccess(withStatus: "Successfully")
  }
  
  func showPreview(_ image: UIImage?) {
    if let window = UIApplication.shared.keyWindow {
      let imgView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: window.screen.bounds.size))
      imgView.image = image
      imgView.contentMode = .scaleToFill
      imgView.tag = 1000
      window.addSubview(imgView)
      
      let clearButton = UIButton(frame: CGRect(x: imgView.frame.width - 50, y: 20, width: 40.0, height: 40.0))
      clearButton.backgroundColor = UIColor.lightGray
      clearButton.addTarget(self, action: #selector(self.closePreview(_:)), for: .touchUpInside)
      clearButton.setImage(UIImage(named: "ic_close"), for: .normal)
      clearButton.tag = 1001
      imgView.addSubview(clearButton)
      imgView.isUserInteractionEnabled = true
    }
  }
  
  @objc private func closePreview(_ sender: Any) {
    guard let window = UIApplication.shared.keyWindow, let imgView = window.viewWithTag(1000) else { return }
    imgView.removeFromSuperview()
  }
  

}
