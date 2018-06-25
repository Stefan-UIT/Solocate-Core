//
//  FileResponse.swift
//  Sel2B
//
//  Created by machnguyen_uit on 6/7/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class UploadFileResponse: BaseModel {
  var msg: String = ""
  var table: String = ""
  var id: String = ""
  
  required public convenience init?(map: Map) {
    self.init()
  }
  
  override public func mapping(map: Map) {
    msg <- map["msg"]
    table <- map["table"]
    id <- map["id"]
    super.mapping(map: map)
  }
}
