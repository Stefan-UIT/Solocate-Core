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
  
  required convenience init?(map: Map) {
    self.init()
  }
    
  func mapping(map: Map) {
    author <- map["author"]
    createdAt <- map["created_at"]
    content <- map["content"]
  }
}

