//
//  LocationTracker.swift
//  SRSDriver
//
//  Created by Trung Vo on 7/3/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import CoreLocation

let DMSLocationManager = LocationTracker.shared

class LocationTracker: NSObject {
    
    static let shared = LocationTracker()
    
    // MARK: - Variables
    private var timer = Timer()
    private var backgroundTaskIdentifier = UIBackgroundTaskIdentifier.init(rawValue: 1)
    
    // MARK: - Utility Methods
    func startUpdatingDriverLocationIfNeeded() {
        // if user did not login, no need to update location
        if !Cache.shared.hasLogin {
            invalidTimer()
            return
        }
        
        scheduledTimerWithTimeInterval()
    }
    
    @objc func requestUpdateDriverLocation() {
        print("update location")
        if !Caches().hasLogin { // suddenly user logout
            invalidTimer()
            return
        }
        
        guard let userLocation = LocationManager.shared.currentLocation else {
            LocationManager.shared.delegate = self
            LocationManager.shared.requestLocation()
            return
        }
        
        let longitude = userLocation.coordinate.longitude
        let latitude = userLocation.coordinate.latitude
        
        if let lastLocationSubmited = Caches().lastLocationSubmited {
            let dist = distance(lat1: lastLocationSubmited.latitude,
                                lon1: lastLocationSubmited.longitude,
                                lat2: latitude,
                                lon2: longitude, unit: "M")

            if dist < DMSAppConfiguration.distanceSubmitLocation {
                return
            }
        }
        
        SERVICES().API.getAllRouteInprogess { (result) in
            switch result{
            case .object(let obj):
                if let routeIds = obj.data as? Array<Int> {
                   SERVICES().API.updateDriverLocation(long: longitude,
                                               lat: latitude, routeIds: routeIds) {(result) in
                    }
                }
                
            case .error(_ ):
                break
            }
        }
    }
    
    // Schedule to update driver location
    func scheduledTimerWithTimeInterval(){
        requestUpdateDriverLocation()
        invalidTimer()
        
        // bring timer to background thread
        self.backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask {
            self.invalidTimer()
        }
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(DMSAppConfiguration.trackingTimeInterval), target: self, selector: #selector(requestUpdateDriverLocation), userInfo: nil, repeats: true)
    }
    
    func invalidTimer() {
        timer.invalidate()
        UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
    }
    
    deinit {
        invalidTimer()
    }
    
    func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta))
        dist = acos(dist)
        dist = rad2deg(dist)
        dist = dist * 60 * 1.1515 // "Miles"
        if (unit == "K") { // "Kilometers"
            dist = dist * 1.609344
        }
        else if (unit == "N") {//Nautical Miles
            dist = dist * 0.8684
        }
        return dist
    }
    
    func deg2rad(_ deg:Double) -> Double {
        return deg * .pi / 180
    }
    
    ///////////////////////////////////////////////////////////////////////
    ///  This function converts radians to decimal degrees              ///
    ///////////////////////////////////////////////////////////////////////
    func rad2deg(_ rad:Double) -> Double {
        return rad * 180.0 / .pi
    }
}

// MARK: - Location Manager Delegate
extension LocationTracker: LocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        requestUpdateDriverLocation()
    }
    
    func didUpdateLocation(_ location: CLLocation?) {
        requestUpdateDriverLocation()
    }
}

