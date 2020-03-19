//
//  ForgetPasswordView.swift
//  DMSDriver
//
//  Created by MrJ on 5/11/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

protocol SKULoadedQuantityInputViewDelegate: class {
    func skuLoadedQuantityInputView(_ view: SKULoadedQuantityInputView, _ loadedQty: Int)
}

class SKULoadedQuantityInputView: BaseView {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var batchIdLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var loadedQtyTextField: UITextField!
    
    weak var delegate: SKULoadedQuantityInputViewDelegate? = nil
    var detail:Order.Detail? = nil
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
        loadedQtyTextField.becomeFirstResponder()
    }
    
    func configureView(detail:Order.Detail) {
        self.detail = detail
        nameLabel.text = Slash(detail.nameReferenceCode)
        barcodeLabel.text = Slash(detail.pivot?.bcd)
        batchIdLabel.text = Slash(detail.pivot?.batch_id)
        quantityLabel.text = IntSlash(detail.pivot?.qty)
        if let loadedQty = detail.pivot?.loadedQty {
            loadedQtyTextField.text = String(loadedQty)
        }
    }
    
    
    // MARK: Action
    @IBAction func tapCancelButtonAction(_ sender: UIButton) {
        removeFromSuperview()
    }
    @IBAction func tapSubmitButtonAction(_ sender: UIButton) {
        removeFromSuperview()
    }
    
}

extension SKULoadedQuantityInputView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == loadedQtyTextField, let text = textField.text {
            let validText = (text.isEmpty) ? "0" : text
            let quantity = Int(validText) ?? 0
            self.detail?.pivot?.loadedQty = quantity
            self.delegate?.skuLoadedQuantityInputView(self, quantity)
        }
    }
}
