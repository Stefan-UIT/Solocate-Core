//
//  UIImage.swift
//  SRSDriver
//
//  Created by phunguyen on 3/16/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import Foundation
import UIKit

//public enum ImageFormat {
//  case png
//  case jpeg(CGFloat)
//}
//
//extension UIImage {
//
//  public func base64(format: ImageFormat) -> String? {
//    var imageData: Data?
//    switch format {
//    case .png: imageData = UIImagePNGRepresentation(self)
//    case .jpeg(let compression): imageData = UIImageJPEGRepresentation(self, compression)
//    }
//    return imageData?.base64EncodedString()
//  }
//}


extension UIImage {
    func cropToBounds(width: CGFloat, height: CGFloat) -> UIImage {
        
        let cgimage = self.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = width
        var cgheight: CGFloat = height
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return image
    }
}

extension UIBarButtonItem {
  @IBInspectable var localizeKey: String {
    get {
      return ""
    } set {
        let localBundle = Bundle(url: App().bundlePath)!
        let text = NSLocalizedString(newValue, tableName: nil, bundle: localBundle, value: "", comment: "")
      self.title = text
    }
  }
}

extension UITabBarItem {
  @IBInspectable var localizeKey: String {
    get {
      return ""
    } set {
        let localBundle = Bundle(url: App().bundlePath)!
        let text = NSLocalizedString(newValue, tableName: nil, bundle: localBundle, value: "", comment: "")
      self.title = text
    }
  }
}
