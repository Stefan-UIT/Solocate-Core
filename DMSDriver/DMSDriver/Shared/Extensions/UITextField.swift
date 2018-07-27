//
//  UITextField.swift
//  truck4less
//
//  Created by phunguyen on 12/18/17.
//  Copyright © 2017 SeldatInc. All rights reserved.
//

import UIKit

extension UITextField {
  
  // scale font
  override open func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    guard let fontName = self.font?.fontName,
      let fontSize = self.font?.pointSize else { return }
    self.font = UIFont(name: fontName, size: fontSize * CGFloat(Constants.FONT_SCALE_VALUE))
  }
  
  @IBInspectable var placeholderKey: String {
    get {
      return ""
    } set {
      self.placeholder = NSLocalizedString(newValue, comment: "")
    }
  }
}
