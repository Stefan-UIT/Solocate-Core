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

extension UIBarButtonItem {
  @IBInspectable var localizeKey: String {
    get {
      return ""
    } set {
      self.title = NSLocalizedString(newValue, comment: "")
    }
  }
}

extension UITabBarItem {
  @IBInspectable var localizeKey: String {
    get {
      return ""
    } set {
      self.title = NSLocalizedString(newValue, comment: "")
    }
  }
}
