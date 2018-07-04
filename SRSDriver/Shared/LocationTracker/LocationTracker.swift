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
    
    // MARK: - Utility Methods
    func startUpdatingDriverLocationIfNeeded() {
        // if user did not login, no need to update location
        if !Cache.shared.hasLogin {
            timer.invalidate()
            return
        }
        scheduledTimerWithTimeInterval()
    }
    
    @objc func requestUpdateDriverLocation() {
        guard let userLocation = LocationManager.shared.currentLocation else {
            LocationManager.shared.delegate = self
            LocationManager.shared.requestLocation()
            return
        }
        API().updateDriverLocation(long: userLocation.coordinate.longitude,
                                   lat: userLocation.coordinate.latitude) { [weak self] (result) in
               print(result)
        }
        
    }
    
    // Schedule to update driver location
    func scheduledTimerWithTimeInterval(){
        requestUpdateDriverLocation()
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(DMSAppConfiguration.trackingTimeInterval), target: self, selector: #selector(requestUpdateDriverLocation), userInfo: nil, repeats: true)
    }
}

// MARK: - Location Manager Delegate
extension LocationTracker: LocationManagerDelegate {
    func didUpdateLocation(_ location: CLLocation?) {
        requestUpdateDriverLocation()
    }
}

