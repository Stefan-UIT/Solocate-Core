//
//  InfoModel.swift
//  Sel2B
//
//  Created by MrJ on 5/8/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class UserRole: BaseModel {
  
    var name:String?
  
  required  init?(map: Map) {
    super.init()
  }
  
  override func mapping(map: Map) {
    name <- map["name"]
  }
}
