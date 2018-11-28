//
//  DriverModel.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 8/15/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper

class CoordinatorDriverModel: SelectionModel {
    var coordinators:[DriverModel]?
    var drivers:[DriverModel]?

    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        coordinators <- map["coordinator"]
        drivers <- map["driver"]
    }
}

class DriverShiftModel: BaseModel {
    var id:String?
    var created_at:String?
    var updated_at:String?
    var name:String?
    var start_time:String?
    var end_time:String?
    var ac:String?
    var created_by:Int?
    var updated_by:Int?
    
    
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        name       <- map["name"]
        start_time <- map["start_time"]
        end_time   <- map["end_time"]
        ac         <- map["ac"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        created_by <- map["created_by"]
        updated_by <- map["updated_by"]
    }
    
    
}

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
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
      super.init()
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
