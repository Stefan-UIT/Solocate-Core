//
//  AddNoteViewController.swift
//  DMSDriver
//
//  Created by Trung Vo on 6/18/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

protocol AddNoteViewControllerDelegate: class {
    func didSubmitNote(_ note:String, images:[AttachFileModel]?)
}

class AddNoteViewController: BaseViewController {
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    
    weak var delegate: AddNoteViewControllerDelegate?
    var attachedFiles:[AttachFileModel]?
    
    var validateSubmit:Bool = false{
        didSet{
            submitButton?.isEnabled = validateSubmit
            submitButton?.alpha = validateSubmit ? 1 : 0.4
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hintLabel.isHidden = true
        validateSubmit = false
        // Do any additional setup after loading the view.
    }
    
    override func updateNavigationBar()  {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        let title = "Add Note"
        App().navigationService.updateNavigationBar(.BackOnly, title.localized, AppColor.white, true)
    }
    
    func handleShowingHintLabel() {
        let numberOfAttachedFiles = self.attachedFiles?.count ?? 0
        if numberOfAttachedFiles > 0 {
            self.hintLabel.isHidden = false
            self.hintLabel.text = "(\(numberOfAttachedFiles) selected images)"
        } else {
            self.hintLabel.isHidden = true
        }
    }
    
    @IBAction func submit(_ sender: UIButton) {
        let message = self.noteTextView?.text ?? ""
        self.delegate?.didSubmitNote(message, images: self.attachedFiles)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAddButtonTouchUp(_ sender: UIButton) {
        ImagePickerView.shared().showImageGallaryMultiPicker(atVC: self) {[weak self] (success, data) in
            self?.attachedFiles = (data.count > 0) ? data : nil
            self?.handleShowingHintLabel()
        }
    }

}

extension AddNoteViewController:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        validateSubmit = (textView.text.length > 0)
    }
}

extension AddNoteViewController:DMSNavigationServiceDelegate {
    func didSelectedBackOrMenu() {
        self.navigationController?.popViewController(animated: true)
    }
}
