//
//  DMSAppConfiguration.swift
//  SRSDriver
//
//  Created by Trung Vo on 7/3/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

let DMSAppConfiguration = AppConfiguration.sharedInstance

class AppConfiguration: NSObject {
    
    static let sharedInstance = AppConfiguration()
    
    // MARK: - Variables
    var trackingTimeInterval:Int = 0
    var reloadRouteTimeInterval:Int = 0
    var isUserAutoRefetchRouteList = false
    var distanceSubmitLocation:Double = 0
    
    
    var baseUrl:String = ""
    var baseUrl_Dev:String = ""
    var baseUrl_Staging:String = ""
    var baseUrl_Product:String = ""
    var baseUrl_Google_Map:String = ""
    
    var pathUrls:[String: String] = [:]

    
    // MARK: - Utility Methods
    func enableConfiguration() {
        loadCustomConfiguration()
        loadCustomServicesConfigs()
    }
    
    private func loadCustomConfiguration() {
        guard let config = readConfigurationFile() else {
            return
        }
        
        if let trackingTimeInterval = config.object(forKey: "TrackingTimeInterval") as? Int {
            self.trackingTimeInterval = trackingTimeInterval
        }
        
        if let reloadRouteTimeInterval = config.object(forKey: "ReloadRouteTimeInterval") as? Int {
            self.reloadRouteTimeInterval = reloadRouteTimeInterval
        }
        
        if let autoRefetchRouteList = config.object(forKey:"AutoRefetchRouteList") as? Bool {
            self.isUserAutoRefetchRouteList = autoRefetchRouteList
        }
        
        if let distanceSubmitLocation = config.object(forKey:"DistanceSubmitLocation") as? Double {
            self.distanceSubmitLocation = distanceSubmitLocation
        }
        
        
        if let url = config.object(forKey: PATH_REQUEST_URL.BASE_URL.rawValue) as? String {
            self.baseUrl = url
        }
        
        if let url = config.object(forKey: PATH_REQUEST_URL.BASE_URL_STAGING.rawValue) as? String {
            self.baseUrl_Staging = url
        }
        
        if let url = config.object(forKey: PATH_REQUEST_URL.BASE_URL_DEV.rawValue) as? String {
            self.baseUrl_Dev = url
        }
        
        if let url = config.object(forKey: PATH_REQUEST_URL.BASE_URL_PRODUCT.rawValue) as? String {
            self.baseUrl_Product = url
        }
        
        if let url = config.object(forKey: PATH_REQUEST_URL.BASE_URL_GOOGLE_MAP.rawValue) as? String {
            self.baseUrl_Google_Map = url
        }
    }
    
    private func loadCustomServicesConfigs() {
        guard let config = readServicesConfigs() else {
            return
        }
       
        self.pathUrls = config as! [String : String]
    }
    
    private func readConfigurationFile() -> NSDictionary? {
        guard let path = Bundle.main.path(forResource: "MainConfigs", ofType: "plist") else {
            return nil
        }
        return NSDictionary(contentsOfFile: path)
    }
    
    private func readServicesConfigs() -> NSDictionary? {
        guard let path = Bundle.main.path(forResource: "ServicesConfigs", ofType: "plist") else {
            return nil
        }
        return NSDictionary(contentsOfFile: path)
    }
}
