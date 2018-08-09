//
//  MapsViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import GoogleMaps

class MapsViewController: UIViewController {
  @IBOutlet weak var mapView: GMSMapView!
  var route: Route? {
    didSet {
      guard mapView != nil else {return}
      drawMap()
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.isMyLocationEnabled = true
    mapView.delegate = self
    drawMap()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = false
  }
  
  func drawPath(fromLocation from: CLLocationCoordinate2D,
                toLocation to: CLLocationCoordinate2D) {
    self.showLoadingIndicator()
    API().getDirection(fromLocation: from, toLocation: to) {[weak self] (result) in
        self?.dismissLoadingIndicator()
        switch result{
        case .object(let obj):
            for route in obj.routes {
                let path = GMSPath(fromEncodedPath: route.polyline)
                let polyLine = GMSPolyline.init(path: path)
                polyLine.strokeWidth = Constants.ROUTE_WIDTH
                polyLine.strokeColor = AppColor.mainColor
                polyLine.map = self?.mapView
                let bounds = GMSCoordinateBounds(path: path!)
                self?.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
            }
        case .error(let error):
            self?.showAlertView(error.getMessage())
        }
    }
  }
    
    private func drawMap() {
        guard let _route = route else {
            return
        }
        mapView.clear()
        showMarkers()
        
        // draw from warehouse to first point
        let pickupLocation = CLLocationCoordinate2D(latitude: route!.warehouse.latitude, longitude: route!.warehouse.longitude)
        if let firstPoint = _route.orderList.first {
            let toLocation = CLLocationCoordinate2D(latitude: firstPoint.lat.doubleValue, longitude: firstPoint.lng.doubleValue)
            drawPath(fromLocation: pickupLocation, toLocation: toLocation)
        }
        
        /*
        // draw from the last point to warehouse
        if _route.orderList.count > 1, let lastPoint = _route.orderList.last {
            let fromLocation = CLLocationCoordinate2D(latitude: lastPoint.lat.doubleValue, longitude: lastPoint.lng.doubleValue)
            drawPath(fromLocation: fromLocation, toLocation: pickupLocation)
        }
        */
        
        // draw two stores together
        let distinctOrderList = _route.distinctArrayOrderList()
        var sortedList = distinctOrderList.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.sequence <= rhs.sequence
        })
        
        for (index, _) in sortedList.enumerated() {
            let nextIndex = index + 1
            if nextIndex >= sortedList.count {
                return
            }
            let beginStore = sortedList[index]
            let nextstore = sortedList[nextIndex]
            
            drawPath(fromLocation:beginStore.location, toLocation:nextstore.location)
        }
    }
    
    private func labelMarkerWithText(_ text:String) -> UILabel {
        let labelOrder = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        labelOrder.text = text
        labelOrder.textAlignment = .center
        labelOrder.textColor = .white
        labelOrder.backgroundColor = .gray
        labelOrder.cornerRadius = 15.0
        labelOrder.clipsToBounds = true
        
        return labelOrder
    }
    
    
    private func showMarker(_ order:Order, sequence:Int) {
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: order.lat.doubleValue, longitude: order.lng.doubleValue))
        let labelOrder = labelMarkerWithText("\(order.sequence)")
        marker.title = "\(order.storeName)"
        marker.snippet = "\(order.deliveryAdd)"
        marker.map = mapView
        marker.iconView = labelOrder
        marker.zIndex = 1
    }
    
    private func showMarkers() {
        let warehouseMarker = route!.warehouse.toGMSMarker() // warehouse marker
        warehouseMarker.map = mapView
        
        let distinctArray = route!.distinctArrayOrderList()
        for (index,order) in distinctArray.enumerated() {
            let seq = index + 1
            showMarker(order, sequence:seq)
        }
    }
}

extension MapsViewController: GMSMapViewDelegate {
  
}
