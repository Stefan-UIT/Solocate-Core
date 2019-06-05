//
//  NoteManagementViewController.swift
//  DMSDriver
//
//  Created by Trung Vo on 6/4/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class NoteManagementViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noteTextView: UITextView?
    @IBOutlet weak var lblPlaceholder: UILabel?
    
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    var validateSubmit:Bool = false{
        didSet{
            finishButton?.isEnabled = validateSubmit
            finishButton?.alpha = validateSubmit ? 1 : 0.4
        }
    }
    var attachedFiles:[AttachFileModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hintLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func updateNavigationBar()  {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.BackOnly, "Note Management".localized, AppColor.white, true)
    }
    
    func handleShowingHintLabel() {
        let numberOfAttachedFiles = self.attachedFiles?.count ?? 0
        if numberOfAttachedFiles > 0 {
            self.hintLabel.isHidden = false
            self.hintLabel.text = "(\(numberOfAttachedFiles) selected images"
        } else {
            self.hintLabel.isHidden = true
        }
    }
    
    // MARK: - ACTION
    @IBAction func submit(_ sender: UIButton) {
        let message = self.noteTextView?.text ?? ""
        submitNoteToRoute(426, message: message, files: self.attachedFiles)
    }
    
    @IBAction func onbtnClickback(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onAddButtonTouchUp(_ sender: UIButton) {
        ImagePickerView.shared().showImageGallaryMultiPicker(atVC: self) {[weak self] (success, data) in
            self?.attachedFiles = (data.count > 0) ? data : nil
            self?.handleShowingHintLabel()
        }
    }
}

extension NoteManagementViewController {
    func submitNoteToRoute(_ routeID:Int, message:String, files:[AttachFileModel]?){
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        
        SERVICES().API.updateNoteToRoute(routeID, message: message, files: files) { [weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
//                self?.fetchData()
                return
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
        
    }
}

extension NoteManagementViewController:DMSNavigationServiceDelegate {
    func didSelectedBackOrMenu() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension NoteManagementViewController:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        lblPlaceholder?.isHidden = (textView.text.length > 0)
        validateSubmit = (textView.text.length > 0)
    }
}
