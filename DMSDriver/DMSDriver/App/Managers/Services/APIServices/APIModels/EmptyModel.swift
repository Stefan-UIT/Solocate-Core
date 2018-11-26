//
//  EmptyModel.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class EmptyModel: BaseModel {
        
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        //
    }

}
