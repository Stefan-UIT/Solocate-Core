//
//  FilterDataModel.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 2/20/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper

class FilterDataModel: BaseModel {
    
    enum SelectingField:Int {
        case DateField = 0
        case TypeField
        case StatusField
        case CustomerField
        case CityField
    }
    
    var date:Date?
    var timeData:TimeDataItem?
    var type:[String]?
    var status:BasicModel?
    var customer:String?
    var city:String?
    
    var selectingField:SelectingField?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        date <- map["date"]
        timeData <- map["timeData"]
        type <- map["type"]
        status <- map["status"]
        customer <- map["customer"]
        city <- map["city"]
        selectingField <- map["selectingField"]
    }
    
    /*
    func cloneObject() -> FilterDataModel? {
        let json = getJSONString()
        let obj = FilterDataModel(JSON: json)
        return obj
    }
     */
}
