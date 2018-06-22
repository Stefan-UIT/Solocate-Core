//
//  LocationManager.swift
//  truck4less
//
//  Created by phunguyen on 1/18/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import Foundation
import MapKit

protocol LocationManagerDelegate: class {
  func didUpdateLocation(_ location: CLLocation?)
}

class LocationManager: NSObject {
  weak var delegate: LocationManagerDelegate?
  static let shared = LocationManager()
  private var locManager = CLLocationManager()
  var currentLocation: CLLocation?
  
  override init() {
    super.init()
  }
  
  func requestLocation() {
    locManager.delegate = self
    locManager.desiredAccuracy=kCLLocationAccuracyBest
    locManager.distanceFilter = 15.0
    if CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .denied {
      locManager.requestAlwaysAuthorization()
      locManager.startUpdatingLocation()
    }
    else {
      locManager.startUpdatingLocation()
    }
  }
  
}

extension LocationManager: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways || status == .authorizedWhenInUse {
      manager.startUpdatingLocation()
    }    
  }
  
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations.first
    self.delegate?.didUpdateLocation(locations.first)
    print("Did update new location \(currentLocation!.coordinate)")
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("LocationManager fail with error \(error.localizedDescription)")
  }
}
