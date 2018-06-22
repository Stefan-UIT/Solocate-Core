//
//  UIButtonDesignable.swift
//  DMSDriver
//
//  Created by MrJ on 5/8/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

//@IBDesignable
class UIButtonDesignable: UIButton {
    
    @IBInspectable var mBackgroundColor: UIColor {
        get {
            return Configs.colorButton
        }
        set {
            updateBackgroundColor(mBackgroundColor)
        }
    }
    
    @IBInspectable var mTextColor: UIColor {
        get {
            return .white
        }
        set {
            updateTextColor(mTextColor)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateLayout()
    }
    
//    override func prepareForInterfaceBuilder() {
//        super.prepareForInterfaceBuilder()
//        updateLayout()
//    }
    
    func updateLayout() {
        updateBackgroundColor(mBackgroundColor)
        updateTextColor(mTextColor)
    }
    
    func updateBackgroundColor(_ color: UIColor) {
        backgroundColor = color
    }
    
    func updateTextColor(_ color: UIColor) {
        setTitleColor(color, for: state)
    }
}
