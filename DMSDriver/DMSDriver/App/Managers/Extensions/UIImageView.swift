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

fileprivate let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func setImageWithURL(url:String?,
                         placeHolderImage:UIImage? = nil,
                         complateDownload:((UIImage?,Error?)-> Void)? = nil)  {
        
        if let _url = url {
            SDWebImageDownloader.shared.setValue("Bearer \(E(Caches().getTokenKeyLogin()))",
                forHTTPHeaderField: "Authorization")

            self.sd_setImage(with: URL(string: _url),
                             placeholderImage: placeHolderImage,
                             options: [.allowInvalidSSLCertificates ,
                                       .retryFailed,
                                       .refreshCached],
                             progress: nil) {(image, error, cacheType, url) in
                                complateDownload?(image,error)
            }
        }else {
            self.image = placeHolderImage
        }
    }
    
    func setImage(withURL imgPath: String, placeholderImage:UIImage? = nil) {
        guard let url = URL(string: imgPath) else { return }
        
        if let cachImage = imageCache.object(forKey: url.absoluteString as NSString) {
            
            self.image = cachImage
            
        }else {
            
            self.image = placeholderImage
            let indicator = UIActivityIndicatorView(style: .white)
            indicator.hidesWhenStopped = true
            indicator.startAnimating()
            self.superview?.addSubview(indicator)
            indicator.center = self.center
            DispatchQueue.global().async {[weak self] in
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    indicator.stopAnimating()
                    indicator.removeFromSuperview()
                    guard let _data = data else {
                        return
                    }
                    self?.image = UIImage(data: _data)
                    if let img = UIImage(data: _data) {
                        imageCache.setObject(img, forKey: url.absoluteString as NSString)
                    }
                }
            }
        }
    }
}
