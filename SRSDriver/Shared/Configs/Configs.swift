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
    
    static let configs: [String : String] = {
        if let bundle = Bundle.main.url(forResource: "MainConfigs", withExtension: "plist"),
            let dic = NSDictionary(contentsOf: bundle) {
            return dic as! [String: String]
        }
        return [String: String]()
    }()
    
    static let colorButton : UIColor = {
        let colorHexString : String = Configs.configs[Configs.getConfigKey(.COLOR_BUTTON)]!
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
