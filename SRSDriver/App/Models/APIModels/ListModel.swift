//
//  List.swift
//  Sel2B
//
//  Created by machnguyen_uit on 6/6/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class ListModel<SUB_OBJECT:BaseModel>: BaseModel {
  
  var contents:[SUB_OBJECT]?
  required public convenience init?(map: Map) {
    self.init()
  }
  
  override public func mapping(map: Map) {
    contents <- map["list"]
    super.mapping(map: map)
  }
  
  public func toArray() -> [SUB_OBJECT]? {
    return contents;
  }
}
