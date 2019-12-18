//
//  CorePurchaseOrderStatus+Ext.swift
//  Gadot Dev
//
//  Created by Phong Nguyen on 12/18/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

extension CorePurchaseOrderStatus{
    func setAttributeFrom(_ status: PurchaseOrderStatus? = nil)  {
        guard let _status = status else {
            return
        }
        id = Int16(_status.id ?? 0)
        name = _status.name
        code = _status.code
    }
    
    func convertToStatusModel() -> PurchaseOrderStatus {
        let status = PurchaseOrderStatus()
        status.id = Int(id)
        status.code = code
        status.name = E(name)
        return status
    }
}
