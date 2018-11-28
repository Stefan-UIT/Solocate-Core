//
//  InfoModel.swift
//  Sel2B
//
//  Created by MrJ on 5/8/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class DrivingRule: BaseModel {
    var message:String?
    var data:Int?
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        message <- map["message"]
        data <- map["data"]
    }
}

class UserRole: BaseModel {
  
    var id:Int?
    var name:String?
  
    required  init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
