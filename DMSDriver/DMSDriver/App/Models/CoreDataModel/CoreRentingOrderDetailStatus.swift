//
//  CoreRentingOrderDetailStatus.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 1/15/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import Foundation

extension CoreRentingOrderDetailStatus{
    func setAttributeFrom(_ status: RentingOrderDetailStatus? = nil)  {
        guard let _status = status else {
            return
        }
        id = Int16(_status.id ?? 0)
        name = _status.name
        code = _status.code
    }
    
    func convertToStatusModel() -> RentingOrderDetailStatus {
        let status = RentingOrderDetailStatus()
        status.id = Int(id)
        status.code = code
        status.name = E(name)
        return status
    }
}
