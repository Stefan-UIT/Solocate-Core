//
//  InfoModel.swift
//  Sel2B
//
//  Created by MrJ on 5/8/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class DataAny: BaseModel {
    var message:String?
    var data:Any?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        message <- map["message"]
        data <- map["data"]
    }
}

class DrivingRule: BaseModel {
    var message:String?
    var data:Int?
    
    override init() {
        super.init()
    }
    
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
    var cd:String?

    required  init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        cd <- map["cd"]
    }
}
