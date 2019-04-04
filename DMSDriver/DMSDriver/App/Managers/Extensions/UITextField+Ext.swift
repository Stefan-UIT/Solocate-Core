//
//  UITextField.swift
//  truck4less
//
//  Created by phunguyen on 12/18/17.
//  Copyright © 2017 SeldatInc. All rights reserved.
//

import UIKit

//MARK: - IBInspectable
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


// MARK: - Properties

extension UITextField {

    public typealias TextFieldConfig = (UITextField) -> Swift.Void
    
    public func config(textField configurate: TextFieldConfig?) {
        configurate?(self)
    }
    
    func left(image: UIImage?, color: UIColor = .black) {
        if let image = image {
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = color
            leftView = imageView
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }
    }
    
    func right(image: UIImage?, color: UIColor = .black) {
        if let image = image {
            rightViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = color
            rightView = imageView
        } else {
            rightViewMode = UITextField.ViewMode.never
            rightView = nil
        }
    }
}

// MARK: - Methods

public extension UITextField {
    
    /// Set placeholder text color.
    ///
    /// - Parameter color: placeholder text color.
    func setPlaceHolderTextColor(_ color: UIColor) {
        self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: color])
    }
    
    /// Set placeholder text and its color
    func placeholder(text value: String, color: UIColor = .red) {
        self.attributedPlaceholder = NSAttributedString(string: value, attributes: [ NSAttributedString.Key.foregroundColor : color])
    }
}

