//
//  CoreRentingOrderStatus+Ext.swift
//  Gadot Dev
//
//  Created by Phong Nguyen on 10/4/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

extension CoreRentingOrderStatus{
    func setAttributeFrom(_ status: RentingOrderStatus? = nil)  {
        guard let _status = status else {
            return
        }
        id = Int16(_status.id ?? 0)
        name = _status.name
        code = _status.code
    }
    
    func convertToStatusModel() -> RentingOrderStatus {
        let status = RentingOrderStatus()
        status.id = Int(id)
        status.code = code
        status.name = E(name)
        return status
    }
}
