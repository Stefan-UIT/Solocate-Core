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
  var markers: [OrderMarker]?
  var route: Route?
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.isMyLocationEnabled = true
    mapView.delegate = self
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let _route = route {
      // order marker
      if let pickupAdd = _route.pickupList.first { // ensure having pickup address
        let pickupMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: pickupAdd.lat, longitude: pickupAdd.lng))
        pickupMarker.title = pickupAdd.shopName
        pickupMarker.map = mapView
        let pickupLocation = CLLocationCoordinate2D(latitude: pickupAdd.lat, longitude: pickupAdd.lng)
        
        if let firstPoint = _route.orderList.first {
          let toLocation = CLLocationCoordinate2D(latitude: firstPoint.lat.doubleValue, longitude: firstPoint.lng.doubleValue)
          drawPath(fromLocation: pickupLocation, toLocation: toLocation)
        }
        if _route.orderList.count > 1, let lastPoint = _route.orderList.last {
          let fromLocation = CLLocationCoordinate2D(latitude: lastPoint.lat.doubleValue, longitude: lastPoint.lng.doubleValue)
          drawPath(fromLocation: fromLocation, toLocation: pickupLocation)
        }
        //
        for m in _route.orderList {
          let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: m.lat.doubleValue, longitude: m.lng.doubleValue))
          let labelOrder = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
          labelOrder.text = "\(m.sequence)"
          labelOrder.textAlignment = .center
          labelOrder.textColor = .white
          labelOrder.backgroundColor = .gray
          labelOrder.cornerRadius = 15.0
          labelOrder.clipsToBounds = true
          marker.title = m.shopName
          marker.map = mapView
          marker.iconView = labelOrder
        }
        
        let sortedList = _route.orderList.sorted(by: { (lhs, rhs) -> Bool in
          return lhs.sequence <= rhs.sequence
        })
        let subList = sortedList.chunked(by: 2)
        for item in subList {
          guard item.count > 1 else { return }
          if let first = item.first, let last = item.last {
            let firstLocation = CLLocationCoordinate2D(latitude: first.lat.doubleValue, longitude: first.lng.doubleValue)
            let lastLocation = CLLocationCoordinate2D(latitude: last.lat.doubleValue, longitude: last.lng.doubleValue)
            drawPath(fromLocation: firstLocation, toLocation: lastLocation)
          }
        }
      }
    }
  }
  
  func drawPath(fromLocation from: CLLocationCoordinate2D, toLocation to: CLLocationCoordinate2D) {
    APIs.getDirection(fromLocation: from, toLocation: to) { (routes) in
      guard let _routes = routes else { return }
      for route in _routes {
        let path = GMSPath(fromEncodedPath: route.polyline)
        let polyLine = GMSPolyline.init(path: path)
        polyLine.strokeWidth = Constants.ROUTE_WIDTH
        polyLine.strokeColor = AppColor.mainColor
        polyLine.map = self.mapView
        let bounds = GMSCoordinateBounds(path: path!)
        self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
      }
    }
  }
  
  
  
}

extension MapsViewController: GMSMapViewDelegate {
  
}
