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
        id = Int16(orderDetail.pivot?.id ?? 0)
        name = orderDetail.name
        barcode = orderDetail.pivot?.bcd
        batchId = orderDetail.pivot?.batch_id
        qty = Int16(orderDetail.pivot?.qty ?? 0)
        loadedQty = Int16(orderDetail.pivot?.loadedQty ?? 0)
        deliveredQty = Int16(orderDetail.pivot?.deliveredQty ?? 0)
    }
    
    func convertToOrderDetailModel() -> Order.Detail {
        let orderDetail = Order.Detail()
        orderDetail.id = Int(id)
        orderDetail.name = name
        let pivotJsonModel = ["bcd": (barcode ?? ""),
                              "batch_id": (batchId ?? ""),
                              "qty": Int(qty) ,
                              "loaded_qty": Int(loadedQty),
                              "delivered_qty": Int(deliveredQty)] as [String : Any]
        let _pivot = Order.Detail.Pivot(JSON: pivotJsonModel)
        orderDetail.pivot = _pivot
        return orderDetail
    }
    
    func setAttributeFrom(_ rentingSKU: RentingOrder.RentingOrderSKU)  {
        id = Int16(rentingSKU.id ?? 0)
        name = rentingSKU.name
//        barcode = IntrentingSKU.barcode ?? 0
        refCode = rentingSKU.referenceCode
    }
    
    func convertToRentingOrderSKUModel() -> RentingOrder.RentingOrderSKU {
        let rentingSKU = RentingOrder.RentingOrderSKU()
        rentingSKU.id = Int(id)
        rentingSKU.name = name
        rentingSKU.referenceCode = refCode
        return rentingSKU
    }
}

