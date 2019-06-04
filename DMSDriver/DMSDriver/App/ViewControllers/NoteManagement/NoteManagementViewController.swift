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
    var validateSubmit:Bool = false{
        didSet{
            finishButton?.isEnabled = validateSubmit
            finishButton?.alpha = validateSubmit ? 1 : 0.4
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func updateNavigationBar()  {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.BackOnly, "Note Management".localized, AppColor.white, true)
    }
    
    // MARK: - ACTION
    @IBAction func submit(_ sender: UIButton) {
        
    }
    
    @IBAction func onbtnClickback(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onAddButtonTouchUp(_ sender: UIButton) {
        ImagePickerView.shared().showImageGallaryMultiPicker(atVC: self) {[weak self] (success, data) in
//            if data.count > 0{
//                self?.uploadMultipleFile(files: data)
//            }
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
