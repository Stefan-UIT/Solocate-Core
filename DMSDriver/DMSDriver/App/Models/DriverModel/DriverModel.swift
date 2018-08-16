//
//  DriverModel.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 8/15/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper

class DriverModel: SelectionModel {
    /**
    "driver_id": 710,
    "driver_name": "Hien Driver Son",
    "role_name": "Driver"
     */
    
    var driver_id = 0
    var driver_name = ""
    var role_name = ""
    
    init(_ id:Int? ,_ name:String?,_ nameRole :String?) {
        super.init()
        driver_id = id ?? 0
        driver_name = E(name)
        role_name = E(nameRole)
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        driver_id <- map["driver_id"]
        driver_name <- map["driver_name"]
        role_name <- map["role_name"]
    }
    
    override var strId: String{
        get{
            return "\(driver_id)"
        }
    }
}
