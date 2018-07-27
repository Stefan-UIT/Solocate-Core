//
//  ChangePasswordModel.swift
//  DMSDriver
//
//  Created by MrJ on 5/10/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class ChangePasswordModel: BaseModel {

    var oldPassword = [String]()
    var newPassword = [String]()
    var rePassword = [String]()
    convenience required init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        oldPassword <- map["old_password"]
        newPassword <- map["new_password"]
        rePassword <- map["repeat_new_password"]
    }
}
