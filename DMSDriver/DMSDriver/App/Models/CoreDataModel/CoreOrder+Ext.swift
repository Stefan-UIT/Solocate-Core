//
//  CoreOrder+Ext.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 9/7/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation

//MARK: - CoreOrder
extension  CoreOrder{
    
    func setAttribiteFrom(_ order:Order) {
        driver_id = Int16(order.driver_id)
        driver_name = order.driver_name
        id =  Int16(order.id)
        locationID = Int16(locationID)
        statusCode = order.statusCode
        statusName = order.statusName
        urgent_type_id = Int32(order.urgent_type_id)
    }
    
    func setAttribiteFrom(_ order:OrderDetail) {
        driver_id = Int16(order.driver_id)
        driver_name = order.driver_name
        id =  Int16(order.id)
        locationID = Int16(locationID)
        
        statusCode = order.statusCode
        statusName = order.statusName
        urgent_type_id = Int32(order.urgent_type_id)
    }
    
    func converToOrder() -> Order {
        let order = Order()
        order.driver_id =  Int(driver_id)
        order.driver_name = E(driver_name)
        order.id =  Int(id)
        order.seq = Int(seq)
        order.statusCode = E(statusCode)
        order.statusName = E(statusName)
        order.urgent_type_id = Int(urgent_type_id)
        
        return order
    }
    
    func converToOrderDetail() -> OrderDetail {
        let order = OrderDetail()
        order.driver_id =  Int(driver_id)
        order.driver_name = E(driver_name)
        order.id =  Int(id)
        order.seq = Int(seq)
        order.statusCode = E(statusCode)
        order.statusName = E(statusName)
        order.urgent_type_id = Int(urgent_type_id)
        order.reason = reason?.convertToReasonOrderCC()
        order.url = url?.convertToUrlFileMoldel()
        
        return order
    }
}
