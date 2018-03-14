//
//  UIImageView.swift
//  truck4less
//
//  Created by phunguyen on 12/26/17.
//  Copyright © 2017 SeldatInc. All rights reserved.
//

import Foundation
import UIKit
extension UIImageView {
  func setImage(withURL imgPath: String) {
    guard let url = URL(string: imgPath) else { return }
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    indicator.hidesWhenStopped = true
    indicator.startAnimating()
    self.superview?.addSubview(indicator)
    indicator.center = self.center
    DispatchQueue.global().async {
      let data = try? Data(contentsOf: url)
      DispatchQueue.main.async {
        indicator.stopAnimating()
        indicator.removeFromSuperview()
        guard let _data = data else {
          return
        }
        self.image = UIImage(data: _data)
      }
    }
    
    
    
  }
  
  
  
}
