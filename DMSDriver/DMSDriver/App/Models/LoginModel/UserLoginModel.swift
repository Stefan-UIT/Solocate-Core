//
//  UserLoginModel.swift
//  Sel2B_REST
//
//  Created by machnguyen_uit on 6/12/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class UserLoginModel: BaseModel {
  var email: String = ""
  var password: String = ""
  
 convenience init(_ login: String,_ pass: String) {
    self.init()
    self.email = login;
    self.password = pass;
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  override func mapping(map: Map) {
    email <- map["email"]
    password <- map["password"]
    super.mapping(map: map)
  }
}
