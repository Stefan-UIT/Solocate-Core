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
        var result:[Order.Detail] = []
        orders?.forEach({ (order) in
            if order.to?.address == address?.address {
                let package = order.details ?? []
                result.append(package)
            }
        })
        
        return result
    }
    
    func getPickupPackages() -> [Order.Detail] {
        var result:[Order.Detail] = []
        orders?.forEach({ (order) in
            if order.from?.address == address?.address {
                let package = order.details ?? []
                result.append(package)
            }
        })
        
        return result
    }
}
