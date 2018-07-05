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
    private var backgroundTaskIdentifier = UIBackgroundTaskIdentifier()
    
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
        API().updateDriverLocation(long: longitude,
                                   lat: latitude) { [weak self] (result) in
               print(result)
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
}

// MARK: - Location Manager Delegate
extension LocationTracker: LocationManagerDelegate {
    func didUpdateLocation(_ location: CLLocation?) {
        requestUpdateDriverLocation()
    }
}

