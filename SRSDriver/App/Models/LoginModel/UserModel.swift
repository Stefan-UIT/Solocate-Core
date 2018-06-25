//
//  LoginModel.swift
//  Sel2B
//
//  Created by MrJ on 5/14/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class UserModel: BaseModel {
    
    var token : String?
    var userName: String?
    var role:[UserRole]?
    
    required init?(map: Map) {
    }
    
    override func mapping(map: Map) {
        token <- map["token"]
        role <- map["role"]
        userName <- map["user_name"]
    }
}
