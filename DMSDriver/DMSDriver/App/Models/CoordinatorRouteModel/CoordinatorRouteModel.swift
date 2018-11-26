//
//  CoordinatorRouteModel.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 8/15/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper

class CoordinatorRoute: BaseModel {
    
    var id = -1
    var date:String?
    var coordinator:[Route]?
    var drivers:[Route]?

    
    
    override init() {
        super.init()
        coordinator = []
        drivers = []
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        coordinator <- map["coordinator"]
        drivers <- map["drivers"]
    }
    
}
