//
//  RESTResponse.swift
//  CoreWebservice
//
//  Created by phunguyen on 3/7/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class RESTResponse: NSObject, Mappable {
  var statusCode: Int = 0
  var message: String = ""
  var data: Any?
  
  override init() {
    statusCode = -1
    message = ""
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    self.message      <- map["msg"]
    self.statusCode   <- map["status_code"]
    self.data         <- map["data"]
  }
}
