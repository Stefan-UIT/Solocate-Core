//
//  ResponseDataModel.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class ResponseDataModel<T: BaseModel>: BaseModel, APIDataPresentable {
  
    var message:String?
    var status:Int?
    var data: T?
    
    var rawData: Data?
    var rawObject: Any?
    
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        message <- map["message"]
        status <- map["status"]
        data <- map["data"]
    }
}

class ResponseDataListModel<T: BaseModel>: BaseModel, APIDataPresentable {
  
  var message:String?
  var status:Int?
  var data:[T]?
  
  var rawData: Data?
  var rawObject: Any?
  
  
  required init?(map: Map) {
    super.init()
  }
  
  override func mapping(map: Map) {
    message <- map["message"]
    status <- map["status"]
    data <- map["data"]
  }
}
