//
//  CustomerModel.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/20/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import Foundation
import ObjectMapper

class CustomerModel: BaseModel {
    var id:Int = -1
    var name = ""
    var contactName = ""
    var phone = ""
    var email = ""
    var address = ""
    var floor = ""
    var apartment = ""
    var number = ""
    var street = ""
    var city = ""
    var state = ""
    var zip = ""
    var latitude = ""
    var longitude = ""
    var active = -1
    var companyId = -1
    var customerId = -1
    var customers:UserModel.UserInfo?
    var types:[BasicModel]?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        contactName <- map["ctt_name"]
        phone <- map["phone"]
        email <- map["email"]
        address <- map["address"]
        floor <- map["floor"]
        apartment <- map["apt"]
        number <- map["number"]
        street <- map["street"]
        city <- map["city"]
        state <- map["state"]
        zip <- map["zip"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        active <- map["active"]
        companyId <- map["company_id"]
        customerId <- map["customer_id"]
        customers <- map["customers"]
        types <- map["types"]
        
    }
}
