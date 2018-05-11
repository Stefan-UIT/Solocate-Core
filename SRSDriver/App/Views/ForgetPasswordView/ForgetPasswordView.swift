//
//  ForgetPasswordView.swift
//  DMSDriver
//
//  Created by MrJ on 5/11/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

protocol ForgetPasswordViewDelegate: class {
    func forgetPasswordView(_ view: ForgetPasswordView, _ email: String)
}

class ForgetPasswordView: BaseView {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    weak var delegate: ForgetPasswordViewDelegate? = nil
    
    override func config() {
        super.config()
        
        addObserverKeyboardWillShow()
    }
    
    override func keyboardWillShow(_ notification: Notification) -> CGFloat {
        let height = super.keyboardWillShow(notification)
        heightConstraint.constant -= height
        return height
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        heightConstraint.constant += keyboardHeight
        super.keyboardWillHide(notification)
    }
    
    override func showViewInView(superView: UIView, isHiddenStatusBar: Bool? = nil) {
        super.showViewInView(superView: superView, isHiddenStatusBar: isHiddenStatusBar)
        emailTextField.becomeFirstResponder()
    }
    
    // MARK: Function
    func handleSubmitEmail() {
        guard let email = emailTextField.text else {
            return
        }
        if delegate != nil {
            delegate?.forgetPasswordView(self, email)
        }
    }
    
    // MARK: Action
    @IBAction func tapCancelButtonAction(_ sender: UIButton) {
        removeFromSuperview()
    }
    @IBAction func tapSubmitButtonAction(_ sender: UIButton) {
        handleSubmitEmail()
    }
    
}
