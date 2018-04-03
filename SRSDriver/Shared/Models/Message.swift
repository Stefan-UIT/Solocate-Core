//
//  Message.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 4/3/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import Foundation

import ObjectMapper

class Message: NSObject, Mappable {
  var id = -1
  var content = ""
  var createdBy = -1
  var createdAt = ""
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    createdAt <- map["created_at"]
    content <- map["content"]
    createdBy <- map["created_by"]
  }
}

