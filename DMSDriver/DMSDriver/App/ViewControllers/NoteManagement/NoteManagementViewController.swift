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
    var slideshow = ImageSlideshow()
    
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
    }
    
    override func updateNavigationBar()  {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        let title = (isRouteNoteManagement) ? "Route #\(route!.id)" : "Order #\(order!.id)"
        App().navigationService.updateNavigationBar(.BackOnly, title.localized, AppColor.white, true)
    }
    
    func redirectToAddNoteVC() {
        let vc:AddNoteViewController = .loadSB(SB: .Common)
//        vc.order = orderDetail
//        vc.notes = orderDetail?.notes ?? []
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
                self?.tableView.reloadData()
                
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
        let files = notes[indexPath.row].files
        if files.count > 0 {
            showSlideImages(files: files)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    } 
}
