//
//  CoreSKU+Ext.swift
//  Gadot Dev
//
//  Created by Phong Nguyen on 10/24/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

extension CoreSKU {
    func setAttributeFrom(_ orderDetail: Order.Detail)  {
        id = Int16(orderDetail.id)
    }
    
    func convertToOrderDetailModel() -> Order.Detail {
        let orderDetail = Order.Detail()
        orderDetail.id = Int(id)
        return orderDetail
    }
}

