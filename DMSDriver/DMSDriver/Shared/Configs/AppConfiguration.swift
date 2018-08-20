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
    
    // Tracking
    var trackingTimeInterval:Int = 0
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
        
        if let url = config.object(forKey: RESTConstants.BASE_URL) as? String {
            self.baseUrl = url
        }
        
        if let url = config.object(forKey: RESTConstants.BASE_URL_STAGING) as? String {
            self.baseUrl_Staging = url
        }
        
        if let url = config.object(forKey: RESTConstants.BASE_URL_DEV) as? String {
            self.baseUrl_Dev = url
        }
        
        if let url = config.object(forKey: RESTConstants.BASE_URL_PRODUCT) as? String {
            self.baseUrl_Product = url
        }
        
        if let url = config.object(forKey: RESTConstants.BASE_URL_GOOGLE_MAP) as? String {
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
