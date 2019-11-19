//
//  BoolModel.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 11/5/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper

class BoolModel:BaseModel {
    
    var data = false
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        data <- map["data"]
    }
}
