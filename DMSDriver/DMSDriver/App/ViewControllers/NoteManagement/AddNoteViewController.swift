//
//  AddNoteViewController.swift
//  DMSDriver
//
//  Created by Trung Vo on 6/18/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import UITextView_Placeholder

protocol AddNoteViewControllerDelegate: class {
    func didSubmitNote(_ note:String, images:[AttachFileModel]?)
}

class AddNoteViewController: BaseViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    
    // MARK: - Delegate
    weak var delegate: AddNoteViewControllerDelegate?
    
    // MARK: - Variables
    var attachedFiles:[AttachFileModel]?
    var validateSubmit:Bool = false{
        didSet{
            submitButton?.isEnabled = validateSubmit
            submitButton?.alpha = validateSubmit ? 1 : 0.4
        }
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextView.placeholder = "write-here".localized
        self.hintLabel.isHidden = true
        validateSubmit = false
        noteTextView.delegate = self
        noteTextView.becomeFirstResponder()
    }
    
    override func updateNavigationBar()  {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        let title = "add-note".localized
        App().navigationService.updateNavigationBar(.Back_AttachedFiles, title.localized, AppColor.white, true)
    }
    
    func handleShowingHintLabel() {
        let numberOfAttachedFiles = self.attachedFiles?.count ?? 0
        if numberOfAttachedFiles > 0 {
            self.hintLabel.isHidden = false
            self.hintLabel.text = "(\(numberOfAttachedFiles) " + "selected-images".localized + " )"
        } else {
            self.hintLabel.isHidden = true
        }
    }
    
    func openDevicePhotos() {
        ImagePickerView.shared().showImageGallaryMultiPicker(atVC: self) {[weak self] (success, data) in
            self?.attachedFiles = (data.count > 0) ? data : nil
            self?.handleShowingHintLabel()
        }
    }
    
    // MARK: - ACTION
    @IBAction func submit(_ sender: UIButton) {
        let message = self.noteTextView?.text ?? ""
        self.delegate?.didSubmitNote(message, images: self.attachedFiles)
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: - TextViewDelegate
extension AddNoteViewController:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        validateSubmit = (textView.text.length > 0)
    }
}

extension AddNoteViewController:DMSNavigationServiceDelegate {
    func didSelectedBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didSelectedRightButton() {
        openDevicePhotos()
    }
}
