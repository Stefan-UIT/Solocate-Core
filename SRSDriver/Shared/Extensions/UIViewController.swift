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
  func showAlertView(_ message: String, completionHandler:((_ action: UIAlertAction) -> Void)? = nil)  {
    let alert = UIAlertController(title: "app_name".localized, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "ok".localized, style: .default, handler: completionHandler)
    alert.addAction(okAction)
    
    present(alert, animated: true, completion: nil)
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
