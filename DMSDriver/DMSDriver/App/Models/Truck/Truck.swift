//
//  Driver.swift
//  DMSDriver
//
//  Created by Trung Vo on 7/29/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation
import ObjectMapper

class Truck:BaseModel {
    
    var id:Int = -1
    var name = "-"
    var maxLoad = 0
    var maxVolume = 0
    var maxFloor = 0
    var type:TruckType?
    
    override init() {
        super.init()
    }
    
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        maxLoad <- map["max_load"]
        maxVolume <- map["max_vol"]
        maxFloor <- map["max_floor"]
        type <- map["type"]
    }
}
