//
//  ChangePasswordView.swift
//  DMSDriver
//
//  Created by MrJ on 5/10/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import SVProgressHUD
import IQKeyboardManager

protocol ChangePasswordViewDelegate: class {
    func changePasswordView(_ view: ChangePasswordView, _ success: Bool, _ errorMessage: String, _ model: ChangePasswordModel?)
}

class ChangePasswordView: BaseView {
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    var arrTextField = [UITextField]()
    
    weak var delegate : ChangePasswordViewDelegate? = nil
    
    override func config() {
        super.config()
        
        arrTextField = [oldPasswordTextField,
                        newPasswordTextField,
                        confirmPasswordTextField]
        
        for textField in arrTextField {
            textField.delegate = self
        }
        
        addObserverKeyboardWillShow()
        
    }
    
    override func keyboardWillShow(_ notification: Notification) -> CGFloat {
        let height = super.keyboardWillShow(notification)
//        bottomConstraint.constant = 10.0
        return height
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        super.keyboardWillHide(notification)
        let heightView = self.frame.height
        let heightContentView = contentView.frame.height
        bottomConstraint.constant = (heightView - heightContentView) / 2
    }
    
    override func showViewInWindow() {
        super.showViewInWindow()
        let heightView = self.frame.height
        let heightContentView = contentView.frame.height
        bottomConstraint.constant = (heightView - heightContentView) / 2
    }
    
    func resetData() {
        for textField in arrTextField {
            textField.text = ""
        }
    }
    
    func handleChangePassword() {
        
        for textField in arrTextField {
            textField.resignFirstResponder()
        }
        
        guard let oldPassword = oldPasswordTextField.text else {
            return
        }
        guard let newPassword = newPasswordTextField.text else {
            return
        }
        guard let confirmPassword = confirmPasswordTextField.text else {
            return
        }
        
        let para = ["old_password": oldPassword,
                    "new_password": newPassword,
                    "confirm_password": confirmPassword]
        
        SVProgressHUD.show()
        weak var weakSelf = self
        SERVICES().API.changePassword(para) {[weak self] (result) in
            SVProgressHUD.dismiss()
            switch result{
            case .object(let obj):
                if weakSelf?.delegate != nil {
                    weakSelf?.delegate?.changePasswordView(self!, true, "your-password-has-been-updated".localized, obj)
                }
                break
            case .error(let error):
                if weakSelf?.delegate != nil {
                    weakSelf?.delegate?.changePasswordView(self!, false, error.getMessage(), nil)
                }
                break
                
            }
        }
    }
    
    @IBAction func tapCancelButtonAction(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    @IBAction func tapChangeButtonAction(_ sender: UIButton) {
        handleChangePassword()
    }
}

extension ChangePasswordView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField != arrTextField.last {
            if let index = arrTextField.index(of: textField) {
                let nextTextField = arrTextField[(index + 1)]
                nextTextField.becomeFirstResponder()
            }
        } else {
            handleChangePassword()
        }
        return true
    }
}
