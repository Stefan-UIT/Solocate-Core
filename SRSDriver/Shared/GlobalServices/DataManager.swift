//
//  DataManager.swift
//  DMSDriver
//
//  Created by MrJ on 5/10/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

enum EnviromentType : Int {
    case DEMO = 0
    case DEV = 1
}

class DataManager: NSObject {
    
    class func getEnviroment() -> EnviromentType {
        guard let type = UserDefaults.standard.value(forKey: "ENVIROMENT") as? Int else {
            return .DEMO
        }
        return EnviromentType(rawValue: type)!
    }
    
    class func setEnviroment(_ type : EnviromentType) {
        switch type {
        case .DEMO:
            UserDefaults.standard.set(0, forKey: "ENVIROMENT")
            break
        case .DEV:
            UserDefaults.standard.set(1, forKey: "ENVIROMENT")
            break
        }
    }
    
    class func changeEnviroment() {
        let type = DataManager.getEnviroment()
        switch type {
        case .DEMO:
            DataManager.setEnviroment(.DEV)
            break
        case .DEV:
            DataManager.setEnviroment(.DEMO)
            break
        }
    }
}
