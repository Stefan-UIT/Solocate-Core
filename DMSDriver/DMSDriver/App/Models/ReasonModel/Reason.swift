//
//  Reason.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 3/21/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class Reason: BaseModel {
    var name = ""
    var id = -1
    var reasonDescription = ""
    var message:String?


    required convenience init?(map: Map) {
        self.init()
    }
  
    override func mapping(map: Map) {
        id <- map["reason_id"]
        name <- map["rsn_fails_name"]
        reasonDescription <- map["des"]
        
        if isEmpty(reasonDescription){
            reasonDescription <- map["reason_desc"]
        }
        if isEmpty(name) {
           name <- map["reason_name"]
        }
    }
}

