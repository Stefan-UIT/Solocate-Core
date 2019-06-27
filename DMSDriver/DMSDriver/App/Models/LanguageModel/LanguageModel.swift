//
//  LanguageModel.swift
//  DMSDriver
//
//  Created by Trung Vo on 6/26/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation
import ObjectMapper

class LanguageModel: BaseModel {
    
    var id:Int = -1
    var name = ""
    var system = ""
    var locale = ""
    var path = ""
    var format = ""
    var language = ""
    
    override init() {
        super.init()
    }
    
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        system <- map["system"]
        locale <- map["locale"]
        path <- map["path"]
        format <- map["format"]
        language <- map["language"]
        
    }
}
