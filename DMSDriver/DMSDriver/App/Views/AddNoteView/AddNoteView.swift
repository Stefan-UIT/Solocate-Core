//
//  AddNoteView.swift
//  SRSDriver
//
//  Created by MrJ on 2/13/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit

protocol AddNoteViewDelegate: class {
    func addNoteView(_ view: AddNoteView, _ note: String)
}

class AddNoteView: BaseView {

    @IBOutlet weak var addNoteTextView: UITextView!
    
    // MARK : Variables
    var delegate: AddNoteViewDelegate? = nil
    
    // MARK: Action
    @IBAction func goBackButtonAction(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    @IBAction func okButtonAction(_ sender: UIButton) {
        if delegate != nil {
            delegate?.addNoteView(self, addNoteTextView.text)
        }
    }
}

extension AddNoteView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "..." {
            textView.text = ""
            textView.textColor = UIColor.white
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "..."
            textView.textColor = UIColor.lightGray
        }
    }

}
