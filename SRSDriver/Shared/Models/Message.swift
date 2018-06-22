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
  var updatedBy = -1
  var createdAt = ""
  var sendFrom = ""
  var sendTo = ""
  var status = -1
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id        <- map["id"]
    createdAt <- map["created_at"]
    content   <- map["content"]
    updatedBy <- map["updated_by"]
    sendFrom  <- map["msg_from"]
    sendTo    <- map["msg_to"]
    status    <- map["sts"]
  }
}

