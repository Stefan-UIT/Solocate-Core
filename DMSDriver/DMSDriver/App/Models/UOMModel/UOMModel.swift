//
//  UOMModel.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/20/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import Foundation
import ObjectMapper

class UOMModel: BasicModel {
    var customers:[CustomerModel]?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        customers <- map["customers"]
    }
}
