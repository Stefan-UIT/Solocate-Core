//
//  StartRouteOrderVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 2/22/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import GoogleMaps

typealias StartRouteOrderVCCallback = (Bool,Order?) -> Void

class StartRouteOrderVC: BaseViewController {
    
    @IBOutlet weak var conBotActionView:NSLayoutConstraint?
    @IBOutlet weak var vAction :UIView?
    @IBOutlet weak var btnHidenViewAction :UIButton?
    @IBOutlet weak var btnStart :UIButton?
    @IBOutlet weak var btnCancel :UIButton?
    @IBOutlet weak var mapView :GMSMapView?
    @IBOutlet weak var lblAddress :UILabel?
    @IBOutlet weak var lblType :UILabel?
    @IBOutlet weak var lblDateTime :UILabel?
    @IBOutlet weak var lblEstimeTime :UILabel?

    
    var order:Order?
    var callback:StartRouteOrderVCCallback?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        drawRouteMap(order: order)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        App().mainVC?.navigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        App().mainVC?.navigationController?.isNavigationBarHidden = false
    }
    
    override func updateUI() {
        super.updateUI()
        let start = Hour24Formater.string(from: order?.from?.start_time?.date ?? Date())
        let end = Hour24Formater.string(from: order?.to?.end_time?.date ?? Date())
        let totalTime = order?.totalEstDuration ?? 0
        let totalKm = order?.totalEstDistance ?? 0

        lblAddress?.text = order?.to?.address
        lblDateTime?.text = "\(start) - \(end)"
        lblEstimeTime?.text = CommonUtils.formatEstTime(seconds: Int64(totalTime))
        lblType?.text = CommonUtils.formatEstKm(met: totalKm)
        
        updateButtonStatus()
    }
    
    func updateButtonStatus() {
        //let driverId = order?.driver_id
        guard let statusOrder = order?.statusOrder else {
            return
        }
        switch statusOrder {
        case .newStatus:
            btnStart?.setTitle("Start".localized.uppercased(), for: .normal)
        case .inProcessStatus:
            btnStart?.setTitle("Finish".localized.uppercased(), for: .normal)
            
        default:
            break
        }
    }

    func drawRouteMap(order:Order?) {
        mapView?.clear()
        showAllMarker(order: order)
        if order?.directionRoute == nil {
            drawDirections(order: order)
        }else {
            for route in order?.directionRoute ?? [] {
                mapView?.drawPath(directionRoute: route)
            }
        }
    }
    
    func setupMapView()  {
        mapView?.isMyLocationEnabled = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }


    //MARK: - ACTION
    @IBAction func onbtnClickButtonRightHeader(btn:UIButton) {
        showSideMenu()
    }
    
    @IBAction func onbtnClickHidenActionView(btn:UIButton) {
        btnHidenViewAction?.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.conBotActionView?.constant = -200
            self.view.layoutSubviews()
            
        }) { (success) in
            //
        }
    }
    
    @IBAction func onbtnClickShowActionView(btn:UIButton) {
        btnHidenViewAction?.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.conBotActionView?.constant = 0
            self.view.layoutSubviews()
            
        }) { (success) in
            //
        }
    }
    
    @IBAction func onbtnClickStart(btn:UIButton) {
        handleStartOrFinishOrder()
    }
    
    @IBAction func onbtnClickSkip(btn:UIButton) {
        ReasonSkipView.show(inView: self.view) {[weak self] (success, reason) in
            guard let _reason = reason else {return}
            self?.cancelOrder(reason: _reason)
        }
    }
}

// MARK: - API
extension StartRouteOrderVC{
    fileprivate func submitSignatureAndFinishOrder(_ file: AttachFileModel) {
        guard let order:Order = order?.cloneObject() else { return }
        let listStatus =  CoreDataManager.getListStatus()
        for item in listStatus {
            if item.code == StatusOrder.deliveryStatus.rawValue{
                order.status = item
                break
            }
        }
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        SERVICES().API.submitSignature(file,order) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.showAlertView("Order:#\(order.id) has delevered successfully.".localized) {[weak self](action) in
                    if order.files == nil{
                        order.files = []
                    }
                    order.files?.append(file)
                    self?.callback?(true,order)
                    self?.navigationController?.popViewController(animated: true)
                }

            case .error(let error):
                self?.showAlertView(error.getMessage())
                break
            }
        }
    }
    
    fileprivate func updateStatusOrder(statusCode: String, cancelReason:Reason? = nil) {
        guard let _orderDetail:Order = order?.cloneObject() else {
            return
        }
        let listStatus =  CoreDataManager.getListStatus()
        for item in listStatus {
            if item.code == statusCode{
                _orderDetail.status = item
                break
            }
        }
        
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        
        SERVICES().API.updateOrderStatus(_orderDetail,reason: cancelReason) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.updateUI()
                self?.callback?(true,_orderDetail)
                if _orderDetail.statusOrder == .deliveryStatus ||
                    _orderDetail.statusOrder == .cancelStatus  ||
                    _orderDetail.statusOrder == .cancelFinishStatus {
                    self?.navigationController?.popViewController(animated: true)
                }
            case .error(let error):
                self?.callback?(false,_orderDetail)
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    fileprivate func cancelOrder(reason:Reason) {
        if order?.statusOrder == .newStatus{
            updateStatusOrder(statusCode: StatusOrder.cancelStatus.rawValue,
                              cancelReason:reason)
        }else{
            updateStatusOrder(statusCode: StatusOrder.cancelFinishStatus.rawValue,
                              cancelReason:reason)
        }
    }
}


// MARK: - PRIVATE FUNTIONS
extension StartRouteOrderVC {
    private func handleStartOrFinishOrder() {
        guard let _orderDetail = order else {return}
        let status:StatusOrder = _orderDetail.statusOrder
        var statusNeedUpdate = status.rawValue
        switch status{
        case .newStatus:
            App().showAlertView("Do you want to start this order?".localized,
                                positiveTitle: "YES".localized,
                                positiveAction: {[weak self] (ok) in
                                    
                                    statusNeedUpdate = StatusOrder.inProcessStatus.rawValue
                                    self?.updateStatusOrder(statusCode: statusNeedUpdate)
                                    
            }, negativeTitle: "NO".localized) { (cancel) in
                //
            }
            
        case .inProcessStatus:
            if _orderDetail.isRequireImage(){
                self.showAlertView("Picture required".localized) {[weak self](action) in
                    self?.showPictureViewController()
                }
                
            }else if (_orderDetail.isRequireSign()) {
                self.showAlertView("Signature required".localized) {[weak self](action) in
                    self?.showSignatureViewController()
                }
                
            }else {
                
                App().showAlertView("Do you want to Finish this order?".localized,
                                    positiveTitle: "YES".localized,
                                    positiveAction: {[weak self] (ok) in
                                        
                                        statusNeedUpdate = StatusOrder.deliveryStatus.rawValue
                                        self?.updateStatusOrder(statusCode: statusNeedUpdate)
                                        
                }, negativeTitle: "NO".localized) { (cancel) in
                    //
                }
            }
            
        default:
            break
        }
    }
    
    private func showPictureViewController() {
        let viewController = PictureViewController()
        let navi = BaseNV(rootViewController: viewController)
        navi.statusBarStyle = .lightContent
        viewController.order = order
        viewController.callback = {[weak self](success,order) in
            if success {
                self?.callback?(true,order)
            }
        }
        present(navi, animated: true, completion: nil)
    }
    
    private func showSignatureViewController() {
        let viewController = SignatureViewController()
        viewController.delegate = self
        viewController.order = order
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    private func drawDirections(order:Order?)  {
        order?.getChunkedListLocation().forEach { (listLocation) in
            if let firstLocation = listLocation.first,
                let lastLocation = listLocation.last  {
                
                let wayPoints = listLocation
                let result = wayPoints.dropFirst()
                let newResult = Array(result.dropLast())
                
                mapView?.drawPath(fromLocation: firstLocation,
                                  toLocation: lastLocation,
                                  wayPoints: newResult,
                                  complation: { (success, directionRoutes) in
                                    order?.directionRoute = directionRoutes
                })
            }
        }
    }
    
    private  func showAllMarker(order:Order?) {
        if let from = order?.from,
            let lat = from.lattd?.doubleValue,
            let lng = from.lngtd?.doubleValue  {
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            mapView?.showMarker(type: .Pickup,
                                location: location,
                                name: order?.from?.name,
                                snippet:  order?.from?.ctt_phone)
        }
        
        if let to = order?.to,
            let lat = to.lattd?.doubleValue,
            let lng = to.lngtd?.doubleValue  {
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            mapView?.showMarker(type: .Delivery,
                                location: location,
                                name: order?.to?.name,
                                snippet:  order?.from?.ctt_phone)
        }
    }
}


//MARK: - SignatureViewControllerDelegate
extension StartRouteOrderVC:SignatureViewControllerDelegate{
    func signatureViewController(view: SignatureViewController, didCompletedSignature signature: AttachFileModel?) {
        if let sig = signature {
            submitSignatureAndFinishOrder(sig)
        }
    }
}

