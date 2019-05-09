//
//  GroupLocatonModel.swift
//  DMSDriver
//
//  Created by Seldat on 5/9/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class GroupLocatonModel: BaseModel {
    var address:Address?
    var orders:[Order]?
    
    func getDeliverPackages() -> [Order.Detail] {
        let result:[Order.Detail] = []
        
    }
}
