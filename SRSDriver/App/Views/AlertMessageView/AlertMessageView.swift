//
//  AlertMessageView.swift
//  DMSDriver
//
//  Created by MrJ on 5/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

protocol AlertMessageViewDelegate: class {
    func alertMessageView(_ alertMessageView: AlertMessageView, _ alertID: String, _ content: String)
}

class AlertMessageView: BaseView {

    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextField!
    weak var delegate: AlertMessageViewDelegate? = nil
    fileprivate var id = ""
    
    func config(_ alertID: String, _ messageAlert: String) {
        id = alertID
        alertTitleLabel.text = messageAlert
    }
    
    func handleSubmit() {
        if delegate != nil {
            delegate?.alertMessageView(self, id, contentTextView.text ?? "")
        }
    }
    
    @IBAction func tapSubmitButtonAction(_ sender: UIButton) {
        handleSubmit()
    }
    
    @IBAction func tapCancelButtonAction(_ sender: UIButton) {
        removeFromSuperview()
    }
}
