//
//  ResultsRequestModel.swift
//  DMSDriver
//
//  Created by MrJ on 5/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class ResultsRequestModel: NSObject, Mappable {
    var status: Bool?
    var listAlertMessage: [AlertModel]?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        status <- map["status"]
        listAlertMessage <- map["data"]
    }
}
