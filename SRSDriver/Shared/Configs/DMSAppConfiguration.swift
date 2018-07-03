//
//  DMSAppConfiguration.swift
//  SRSDriver
//
//  Created by Trung Vo on 7/3/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

let appConfiguration = DMSAppConfiguration.sharedInstance

class DMSAppConfiguration: NSObject {
    
    static let sharedInstance = DMSAppConfiguration()
    
    // MARK: - Variables
    
    // Tracking
    var trackingTimeInterval:Int = 0
    
    // MARK: - Utility Methods
    func enableConfiguration() {
        loadCustomConfiguration()
    }
    
    func loadCustomConfiguration() {
        guard let config = readConfigurationFile() else {
            return
        }
        
        if let trackingTimeInterval = config.object(forKey: "TrackingTimeInterval") as? Int {
            self.trackingTimeInterval = trackingTimeInterval
        }
    }
    
    private func readConfigurationFile() -> NSDictionary? {
        guard let path = Bundle.main.path(forResource: "MainConfigs", ofType: "plist") else {
            return nil
        }
        return NSDictionary(contentsOfFile: path)
    }
}
