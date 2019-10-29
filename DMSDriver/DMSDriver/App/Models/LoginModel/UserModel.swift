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
    
    class UserInfo: BaseModel {
        
        var id: Int = 0
        var email: String?
        var firstName : String?
        var lastName : String?
        var mobile : String?
        var phone : String?
        var userName: String?
        var assign_coord = 0
        var timeZoneCompany:String?
        var avatar_native:String?
        var avatar_thumb:String?
        var companyID: Int?
        var supervisorID: Int?
        var company:Company?
        
        required init?(map: Map) {
            super.init()
        }
        
        override init() {
            super.init()
        }
        
        convenience init?(username:String?) {
            self.init()
            self.userName = username
        }
        
        override func mapping(map: Map) {
            id <- map[KEY_USER_ID]
            email <- map[KEY_EMAIL]
            firstName <- map[KEY_FIRST_NAME]
            lastName <- map[KEY_LAST_NAME]
            mobile <- map[KEY_MOBILE]
            phone <- map[KEY_PHONE]
            assign_coord <- map[KEY_ASSIGN_COORD]
            timeZoneCompany <- map[KEY_TIMEZONE_COMPANY]
            avatar_native <- map[KEY_AVARTAR_NATIVE]
            avatar_thumb <- map[KEY_AVARTAR_THUMB]
            companyID <- map["company_id"]
            company <- map["company"]

            let user_name = map[KEY_USER_NAME].currentValue
            
            if user_name == nil {
                userName <- map["username"]
            } else {
                userName <- map[KEY_USER_NAME]
            }
        }
    }
    
    
    var roles:[UserRole]?
    var token : String?
    var userInfo:UserInfo?
    var isRampManager:Bool {
        var isRamp = false
        for item in roles ?? [] {
            if E(item.cd) == "RM"{
                isRamp = true
                break
            }
        }
        return isRamp
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        token <- map[KEY_TOKEN]
        userInfo <- map[KEY_USER_INFO]
        roles <-  map[KEY_ROLES]
    }
    
    func isAssignCoord() -> Bool {
        return userInfo?.assign_coord == 1
    }
    
    fileprivate (set) lazy var isAdmin:Bool =  {
        var isAdmin = false
        for item in roles ?? [] {
            if E(item.cd) == "A"{
                isAdmin = true
                break
            }
        }
        return isAdmin
    }()
    
    fileprivate (set) lazy var isDriver:Bool =  {
        var isDriver = false
        for item in roles ?? [] {
            if E(item.cd) == "D"{
                isDriver = true
                break
            }
        }
        return isDriver
    }()
    
    fileprivate (set) lazy var isCoordinator:Bool =  {
        var isCoordinator = false
        for item in roles ?? [] {
            if E(item.name) == "Coordinator"{
                isCoordinator = true
                break
            }
        }
        return isCoordinator
    }()
    
    fileprivate (set) lazy var isSupperAdmin:Bool =  {
        var isCoordinator = false
        for item in roles ?? [] {
            if E(item.cd) == "SA"{
                isCoordinator = true
                break
            }
        }
        return isCoordinator
    }()
    
    fileprivate (set) lazy var isCustomerBCO:Bool =  {
        var isCoordinator = false
        for item in roles ?? [] {
            if E(item.cd) == "BCO"{
                isCoordinator = true
                break
            }
        }
        return isCoordinator
    }()
}
