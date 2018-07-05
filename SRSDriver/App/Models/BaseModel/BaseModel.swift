//
//  BaseModal.swift
//  Sel2B
//
//  Created by machnguyen_uit on 6/5/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class BaseModel: NSObject, Mappable  {
  
  required public convenience init?(map: Map) {
    self.init()
  }
    
  func mapping(map: Map) {
    //
  }
  
  func getJSONString()-> [String: Any] {
    let json = self.toJSON()
    return json
  }
  
  func getJsonObject(method: ParamsMethod)-> Any {
    return self.getJSONString();
  }
}
