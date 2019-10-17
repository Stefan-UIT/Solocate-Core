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

    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var slideshow = ImageSlideshow()
    
    @IBOutlet weak var noteButton: UIButton!
    var route:Route?
    var order:Order?
    var notes = [Note]()
    
    var isRouteNoteManagement:Bool {
        get {
            return (route != nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        reloadUI()
//        noteButton.backgroundColor = UIColor(red: 171/255, green: 178/255, blue: 186/255, alpha: 1.0)
        // Shadow and Radius
        noteButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        noteButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        noteButton.layer.shadowOpacity = 1.0
        noteButton.layer.shadowRadius = 20.0
        noteButton.layer.masksToBounds = false
//        noteButton.layer.cornerRadius = 4.0

    }
    
    override func updateNavigationBar()  {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        let title = (isRouteNoteManagement) ? ("Route".localized + " #\(route!.id)") : ("order".localized + " #\(order!.id)")
        App().navigationService.updateNavigationBar(.BackOnly, title.localized, AppColor.white, true)
    }
    
    func reloadUI() {
        let isHasData = notes.count > 0
        noDataLabel.isHidden = isHasData
        tableView.isHidden = !isHasData
    }
    
    func redirectToAddNoteVC() {
        let vc:AddNoteViewController = .loadSB(SB: .Common)
//        vc.order = orderDetail
//        vc.notes = orderDetail?.notes ?? []
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - ACTION
    
    
    @IBAction func onAddNoteTouchUp(_ sender: UIButton) {
        redirectToAddNoteVC()
        
    }
    
    @IBAction func onbtnClickback(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension NoteManagementViewController {
    
    func updateAttachFilesParamsProperty(attachedFiles:[AttachFileModel]?) {
        guard let files = attachedFiles else { return }
        for i in 0..<files.count {
            files[i].param = "files[\(i)]"
        }
    }
    
    
    func submitNoteToOrder(_ orderID:Int, message:String, files:[AttachFileModel]?){
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        
        updateAttachFilesParamsProperty(attachedFiles: files)
        SERVICES().API.updateNoteToOrder(orderID, message: message, files: files) { [weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.fetchOrderData()
                self?.showAlertView("updated-successful".localized)
                return
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    func submitNoteToRoute(_ routeID:Int, message:String, files:[AttachFileModel]?){
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        
        updateAttachFilesParamsProperty(attachedFiles: files)
        SERVICES().API.updateNoteToRoute(routeID, message: message, files: files) { [weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.fetchRouteData()
                self?.showAlertView("updated-successful".localized)
                return
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }

    
    func fetchRouteData()  {
        if let route = self.route {
            getRouteDetail("\(route.id)")
        }
    }
    
    func fetchOrderData()  {
        if let order = self.order {
            getOrderDetail(order.id)
        }
    }
    
    func getRouteDetail(_ routeID:String) {
        self.showLoadingIndicator()
        SERVICES().API.getRouteDetail(route: routeID) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(let obj):
                self?.route = obj.data
                self?.notes = (self?.route?.notes)!
                self?.reloadUI()
                self?.tableView.reloadData()
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    func getOrderDetail(_ orderID:Int) {
        showLoadingIndicator()
        
        SERVICES().API.getOrderDetail(orderId: "\(orderID)") {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(let object):
                self?.order = object.data
                self?.notes = (self?.order?.notes)!
                self?.reloadUI()
                self?.tableView.reloadData()
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}

extension NoteManagementViewController:AddNoteViewControllerDelegate {
    func didSubmitNote(_ note: String, images: [AttachFileModel]?) {
        if isRouteNoteManagement {
            self.submitNoteToRoute(route!.id, message: note, files: images)
        } else {
            self.submitNoteToOrder(order!.id, message: note, files: images)
        }
    }
}


extension NoteManagementViewController:DMSNavigationServiceDelegate {
    func didSelectedBackAction() {
        self.navigationController?.popViewController(animated: true)
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
            cell.delegate = self
            let note = notes[indexPath.row]
            cell.note = note
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
//        let files = notes[indexPath.row].files
//        if files.count > 0 {
//            showSlideImages(files: files)
//        }
//
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    } 
}

extension NoteManagementViewController:NoteTableViewCellDelegate {
    func didTouchOnCollectionView(_ note: Note) {
        let files = note.files
        if files.count > 0 {
            showSlideImages(files: files)
        }
    }
}
