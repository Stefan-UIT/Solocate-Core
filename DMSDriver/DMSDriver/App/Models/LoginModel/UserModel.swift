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
    
    var userID: Int?
    var email: String?
    var firstName : String?
    var lastName : String?
    var mobile : String?
    var phone : String?
    var token : String?
    var userName: String?
    var role:[UserRole]?
    
    required init?(map: Map) {
    }
    
    override func mapping(map: Map) {
        userID <- map[KEY_USER_ID]
        email <- map[KEY_EMAIL]
        firstName <- map[KEY_FIRST_NAME]
        lastName <- map[KEY_LAST_NAME]
        mobile <- map[KEY_MOBILE]
        phone <- map[KEY_PHONE]
        token <- map[KEY_TOKEN]
        
        let user_role = map[KEY_USER_ROLE].currentValue
        
        if user_role == nil {
            role <-  map["role"]
        }else{
            role <-  map["user_roles"]
        }
        
        let user_name = map["user_name"].currentValue

        if user_name == nil {
            userName <- map["username"]
        } else {
            userName <- map["user_name"]
        }
    }
    
    fileprivate (set) lazy var isAdmin:Bool =  {
        var isAdmin = false
        for item in role ?? [] {
            if E(item.name) == "Admin"{
                isAdmin = true
                break
            }
        }
        return isAdmin
    }()
    
    fileprivate (set) lazy var isDriver:Bool =  {
        var isDriver = false
        for item in role ?? [] {
            if E(item.name) == "Driver"{
                isDriver = true
                break
            }
        }
        return isDriver
    }()
    
    fileprivate (set) lazy var isCoordinator:Bool =  {
        var isCoordinator = false
        for item in role ?? [] {
            if E(item.name) == "Coordinator"{
                isCoordinator = true
                break
            }
        }
        return isCoordinator
    }()
}
