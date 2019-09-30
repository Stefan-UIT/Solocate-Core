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
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)

}

class LocationManager: NSObject {
    weak var delegate: LocationManagerDelegate?
    static let shared = LocationManager()
    private var locManager = CLLocationManager()
    var currentLocation: CLLocation?
    var userLocation = CLLocationCoordinate2D()
    override init() {
        super.init()
    }
  
//    func requestLocation() {
//        locManager.delegate = self
//        locManager.desiredAccuracy=kCLLocationAccuracyBest
//        locManager.distanceFilter = kCLDistanceFilterNone
//        locManager.pausesLocationUpdatesAutomatically = false
//
//        if CLLocationManager.authorizationStatus() == .notDetermined {
//            locManager.requestAlwaysAuthorization()
//            locManager.startUpdatingLocation()
//
//        }else if (CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted) {
//
//            App().showAlertView("order_detail_access_location".localized,
//                                "1.Location -> 2.Tap Always or While Using the App".localized,
//                                positiveTitle: "Setting".localized,
//                                positiveAction: { (hasOK) in
//
//                                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
//                                          options: [:],
//                                          completionHandler: nil)
//            })
//
//        }else {
//          locManager.startUpdatingLocation()
//        }
//    }
    func requestLocation() {
            self.locManager.delegate = self
            self.locManager.desiredAccuracy=kCLLocationAccuracyBest
            self.locManager.distanceFilter = kCLDistanceFilterNone
            self.locManager.pausesLocationUpdatesAutomatically = false
    //        locManager.allowsBackgroundLocationUpdates = true
            if CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted{
                self.locManager.requestAlwaysAuthorization()
            }
            
                self.locManager.startUpdatingLocation()
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
    delegate?.locationManager(manager, didChangeAuthorization: status)
  }
  
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations.first
    userLocation = manager.location!.coordinate
    self.delegate?.didUpdateLocation(locations.first)
    print("Did update new location \(currentLocation!.coordinate)")
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("LocationManager fail with error \(error.localizedDescription)")
  }
}
