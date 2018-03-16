//
//  OrderDetailMapViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/16/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import GoogleMaps

class OrderDetailMapViewController: UIViewController {
  @IBOutlet weak var mapView: GMSMapView!
  
  var orderLocation: CLLocationCoordinate2D?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.isMyLocationEnabled = true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let _locattion = orderLocation {
      mapView.animate(toLocation: _locattion)
      let marker = GMSMarker(position: _locattion)
      marker.map = mapView
    }
  }
  
}
