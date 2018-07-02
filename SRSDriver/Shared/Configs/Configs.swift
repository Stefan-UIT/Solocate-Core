//
//  Configs.swift
//  DMSDriver
//
//  Created by MrJ on 5/8/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import Foundation

class Configs: NSObject {
    
  static func MainConfigs(_ key:String) -> String? {
    if let bundle = Bundle.main.url(forResource: "MainConfigs", withExtension: "plist"),
      let dic = NSDictionary(contentsOf: bundle) {
      return dic[key] as? String
    }
    return nil
  }
  
  static func ServicesConfigs(_ key:String) -> String? {
    if let bundle = Bundle.main.url(forResource: "ServicesConfigs", withExtension: "plist"),
      let dic = NSDictionary(contentsOf: bundle) {
      return dic[key] as? String
    }
    return nil
  }
  
    static let colorButton : UIColor = {
        let colorHexString : String = Configs.MainConfigs(Configs.getConfigKey(.COLOR_BUTTON))!
        return UIColor(hex: colorHexString)
    }()
    
    class func getConfigKey(_ configKey: ConfigKey) -> String {
        switch configKey {
        case .COLOR_BUTTON:
            return "COLOR_BUTTON"
        }
    }
}

enum ConfigKey {
    case COLOR_BUTTON
}
