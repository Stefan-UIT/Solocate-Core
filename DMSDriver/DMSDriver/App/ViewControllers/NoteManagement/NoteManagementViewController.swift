//
//  NoteManagementViewController.swift
//  DMSDriver
//
//  Created by Trung Vo on 6/4/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import ImageSlideshow
import SDWebImage

class NoteManagementViewController: BaseViewController {
    
    let CELL_IDENTIFIER = "NoteTableViewCell"

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noteTextView: UITextView?
    @IBOutlet weak var lblPlaceholder: UILabel?
    
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    var slideshow = ImageSlideshow()
    var validateSubmit:Bool = false{
        didSet{
            finishButton?.isEnabled = validateSubmit
            finishButton?.alpha = validateSubmit ? 1 : 0.4
        }
    }
    var route:Route?
    var order:Order?
    var notes = [Note]()
    
    var attachedFiles:[AttachFileModel]?
    var isRouteNoteManagement:Bool {
        get {
            return (route != nil)
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
        App().navigationService.updateNavigationBar(.BackOnly, "Note Management".localized, AppColor.white, true)
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
    
    // MARK: - ACTION
    @IBAction func submit(_ sender: UIButton) {
        let message = self.noteTextView?.text ?? ""
        if isRouteNoteManagement {
            submitNoteToRoute(route!.id, message: message, files: self.attachedFiles)
        }
        
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
    func clearData() {
        self.attachedFiles = nil
        self.handleShowingHintLabel()
        self.noteTextView?.text = ""
    }
    
    func updateAttachFilesParamsProperty() {
        guard let files = attachedFiles else { return }
        for i in 0..<files.count {
            files[i].param = "files[\(i)]"
        }
    }
    
    func submitNoteToRoute(_ routeID:Int, message:String, files:[AttachFileModel]?){
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        
        updateAttachFilesParamsProperty()
        SERVICES().API.updateNoteToRoute(routeID, message: message, files: files) { [weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
//                self?.fetchData()
                self?.clearData()
                self?.validateSubmit = false
                self?.showAlertView("Updated Successful".localized)
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

extension NoteManagementViewController:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER, for: indexPath) as? NoteTableViewCell {
            let note = notes[indexPath.row]
            cell.configureCell(note: note)
            
            return cell
        }
        return UITableViewCell()
    }
    
    func showSlideImages(files:[AttachFileModel]) {
        slideshow.slideshowInterval = 5.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIView.ContentMode.scaleAspectFill
        slideshow.circular = false
        
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        slideshow.pageIndicator = pageControl
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator()
//        slideshow.delegate = self
        
        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideshow.setImageInputs(files)
        
        let fullScreenController = slideshow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let files = notes[indexPath.row].files
        if files.count > 0 {
            showSlideImages(files: files)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}
