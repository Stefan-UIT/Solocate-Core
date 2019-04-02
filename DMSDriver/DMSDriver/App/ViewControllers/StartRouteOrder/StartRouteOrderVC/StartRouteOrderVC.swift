//
//  StartRouteOrderVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 2/22/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import GoogleMaps

class StartRouteOrderVC: BaseViewController {
    
    @IBOutlet weak var conBotActionView:NSLayoutConstraint?
    @IBOutlet weak var vAction :UIView?
    @IBOutlet weak var btnHidenViewAction :UIButton?
    @IBOutlet weak var mapView :GMSMapView?
    @IBOutlet weak var lblAddress :UILabel?
    @IBOutlet weak var lblType :UILabel?
    @IBOutlet weak var lblDateTime :UILabel?
    @IBOutlet weak var lblEstimeTime :UILabel?

    
    var order:Order?
    
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
        let viewController = PictureViewController()
        let navi = BaseNV(rootViewController: viewController)
        navi.statusBarStyle = .lightContent
        present(navi, animated: true, completion: nil)
    }
    
    @IBAction func onbtnClickSkip(btn:UIButton) {
        ReasonSkipView.show(inView: self.view) { (success, reaaon) in
            //
        }
    }
}

// MARK: - PRIVATE FUNTIONS
extension StartRouteOrderVC {
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
            mapView?.showMarker(type: .From,
                                location: location,
                                name: order?.from?.name,
                                snippet:  order?.from?.ctt_phone)
        }
        
        if let to = order?.to,
            let lat = to.lattd?.doubleValue,
            let lng = to.lngtd?.doubleValue  {
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            mapView?.showMarker(type: .To,
                                location: location,
                                name: order?.to?.name,
                                snippet:  order?.from?.ctt_phone)
        }
    }
}
