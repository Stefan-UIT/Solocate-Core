//
//  SelectionModel.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 8/15/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper

class SelectionModel: BaseModel {
    var isSelected:Bool = false
    
    var strId:String {
        get{
            return "StrId"
        }
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
}
