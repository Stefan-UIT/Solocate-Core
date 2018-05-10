//
//  CheckTokenModel.swift
//  DMSDriver
//
//  Created by MrJ on 5/10/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class CheckTokenModel: NSObject, Mappable {

    var name = ""
    var message = ""
    var code = 0
    var status = 0
    var type = ""
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        message <- map["message"]
        code <- map["code"]
        status <- map["status"]
        type <- map["type"]
    }
}
