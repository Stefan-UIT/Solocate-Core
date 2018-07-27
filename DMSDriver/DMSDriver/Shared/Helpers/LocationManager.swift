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
    
    func stopUpdatingLocation() {
        locManager.stopUpdatingLocation()
    }
    
    func getPrivacy() {
        if !CLLocationManager.locationServicesEnabled() {
            print("Couldn't turn on ranging: Location services are not enabled.")
            return
        }
        
        if !CLLocationManager.isRangingAvailable() {
            print("Couldn't turn on ranging: Ranging is not available.")
            return
        }
        
        if !locManager.rangedRegions.isEmpty {
            print("Didn't turn on ranging: Ranging already on.")
            return
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            print("success")
        case .denied, .restricted:
            print("Couldn't turn on ranging: Required Location Access (When In Use) missing.")
            
        case .notDetermined:
            locManager.requestWhenInUseAuthorization()
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
