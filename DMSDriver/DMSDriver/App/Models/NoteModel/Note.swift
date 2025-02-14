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
    var id = -1
    var content = ""
    var statusId = -1
    var createdBy:UserModel.UserInfo!
    var createdAt = ""
    var files = [AttachFileModel]()
    var status:Status!
  
  required convenience init?(map: Map) {
    self.init()
  }
    
  func mapping(map: Map) {
    id <- map["id"]
    statusId <- map["status_id"]
    createdBy <- map["created_by"]
    status <- map["shipping_status"]
    createdAt <- map["created_at"]
    content <- map["content"]
    
    content = decode(content) ?? ""
  }
    
    func encode(_ s: String) -> String {
        let data = s.data(using: .nonLossyASCII, allowLossyConversion: true)!
        return String(data: data, encoding: .utf8)!
    }
    
    func decode(_ s: String) -> String? {
        let data = s.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII)
    }
}

