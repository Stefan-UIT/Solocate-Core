//
//  FilterDataModel.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 2/20/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class FilterDataModel: BaseModel {
    
    enum SelectingField:Int {
        case DateField = 0
        case TypeField
        case StatusField
        case CustomerField
        case CityField
    }
    
    var date:Date?
    var type:[String]?
    var status:String?
    var customer:String?
    var city:String?
    
    var selectingField:SelectingField?
    
}
