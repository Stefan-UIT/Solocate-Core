//
//  UIImageView.swift
//  truck4less
//
//  Created by phunguyen on 12/26/17.
//  Copyright © 2017 SeldatInc. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    func setImageWithURL(url:String?,
                         placeHolderImage:UIImage? = nil,
                         complateDownload:((UIImage?,Error?)-> Void)? = nil)  {
        
        if let _url = url {
            let manager = SDWebImageManager.shared()
            manager.imageDownloader?.setValue("Bearer \(E(Caches().getTokenKeyLogin()))",
                forHTTPHeaderField: "Authorization")
            
            self.sd_setImage(with: URL(string: _url),
                             placeholderImage: placeHolderImage,
                             options: [.allowInvalidSSLCertificates ,
                                       .continueInBackground,
                                       .retryFailed,
                                       .refreshCached,
                                       .cacheMemoryOnly],
                             progress: nil) {(image, error, cacheType, url) in
                                complateDownload?(image,error)
            }
        }else {
            self.image = placeHolderImage
        }
    }
    
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
