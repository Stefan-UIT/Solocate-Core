//
//  Note.swift
//  SRSDriver
//
//  Created by phunguyen on 3/16/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class Note: NSObject, Mappable {
  var author = ""
  var createdAt = ""
  var content = ""
    
    var updatedBy = ""
    var statusName = ""
    var id = 0
    var files = [AttachFileModel]()
    var user:UserModel.UserInfo!
    var status:Status!
  
  required convenience init?(map: Map) {
    self.init()
  }
    
  func mapping(map: Map) {
    author <- map["author"]
    createdAt <- map["created_at"]
    content <- map["content"]
    updatedBy <- map["updated_by"]
    statusName <- map["status_name"]
    id <- map["id"]
    files <- map["files"]
    user <- map["users"]
    status <- map["status_route"]
  }
}

