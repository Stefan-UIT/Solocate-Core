//
//  LoginModel.swift
//  Sel2B
//
//  Created by MrJ on 5/14/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreData


class UserModel: BaseModel {
    
    class UserInfo: BaseModel {
        
        struct Pivot:Mappable {
            var locationId:Int?
            var customerId:Int?
            var consigneeName:String?
            var consigneePhone:String?
            var consigneeEmail:String?
            var openTime:String?
            var closeTime:String?
            var remark:String?
            
            init?(map: Map) {
                //
            }
            
            mutating func mapping(map: Map) {
                locationId <- map["location_id"]
                customerId <- map["customer_id"]
                consigneeName <- map["consignee_name"]
                consigneePhone <- map["consignee_phone"]
                consigneeEmail <- map["consignee_email"]
                openTime <- map["open_time"]
                closeTime <- map["close_time"]
                
                if openTime != nil && openTime?.count > 5 {
                    openTime?.removeLast(3)
                }
                if closeTime != nil && closeTime?.count > 5 {
                    closeTime?.removeLast(3)
                }
                
                remark <- map["remark"]
            }
        }
        
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
        var pivot:Pivot?
        
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
            pivot <- map["pivot"]

            let user_name = map[KEY_USER_NAME].currentValue
            
            if user_name == nil {
                userName <- map["username"]
            } else {
                userName <- map[KEY_USER_NAME]
            }
        }
        
        func toCoreUserInfo(context:NSManagedObjectContext) -> CoreUserInfo {
            var result : [NSManagedObject] = []
            //        let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CoreUserInfo")
            fetchRequest.predicate = NSPredicate(format: "id = \(id)")
            do {
                result = try context.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            guard let coreUserInfo = result.first else {
                let userInfoDB = NSEntityDescription.entity(forEntityName: "CoreUserInfo", in: context)
                let _coreUserInfo:CoreUserInfo = CoreUserInfo(entity: userInfoDB!,
                                                              insertInto: context)
                _coreUserInfo.id = Int32(id)
                _coreUserInfo.email = email
                _coreUserInfo.firstName = firstName
                _coreUserInfo.lastName = lastName
                _coreUserInfo.userName = userName
                _coreUserInfo.phone = phone
                _coreUserInfo.companyId = Int16(companyID ?? -1)
                
//                print("Find DB At: ", FileManager.default.urls(for: .documentDirectory,
//                                                               in: .userDomainMask).last ?? "Not Found!")
                do {
                    try context.save()
                } catch {
                    //  let nserror = error as NSError
                    //  print("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                return _coreUserInfo
            }
            return coreUserInfo as! CoreUserInfo
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
