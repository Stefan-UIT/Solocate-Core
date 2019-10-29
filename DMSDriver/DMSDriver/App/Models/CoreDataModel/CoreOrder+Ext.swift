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
        statusCode = order.status?.code
        statusName = order.status?.name
        urgent_type_id = Int32(order.urgent_type_id)
        statusCode = order.statusCode
        custumer_name = order.customer?.userName
        consigneeName = order.isPickUpType ? order.from?.ctt_name : order.to?.ctt_name
        orderType = order.orderType.name
        from_address_full_addr = order.from?.address
        toAddressFullAddress = order.to?.address
        purchaseId = Int16(order.purchaseOrderID)
        division = order.division?.name
        zoneName = order.zone?.name
        remark = order.remark
        typeId = Int16(order.typeID)
        
         detail?.addingObjects(from: order.details ?? [])
        // Pick up
        pickupContactName = order.from?.name
        pickupContactPhone = order.from?.phone
        
        
        // Delivery
        deliveryContactName = order.to?.name
        deliveryContactPhone = order.to?.phone
        
        
       
    }
    
    func converToOrder() -> Order {
        let order = Order()
        order.driver_id =  Int(driver_id)
        order.driver_name = E(driver_name)
        order.id =  Int(id)
        order.seq = Int(seq)
        order.urgent_type_id = Int(urgent_type_id)
        order.consigneeNameCoreData = consigneeName ?? ""
        order.remark = remark
        order.purchaseOrderID = Int(purchaseId)
        
        let status = Status()
        status.code = statusCode
        status.name = statusName
        order.status = status
        
//        let customer = UserModel.UserInfo(map: <#Map#>)
        let customer = UserModel.UserInfo(username: custumer_name)
//        let json = ["username" : custumer_name]
//        let customer = UserModel.UserInfo(map: json)
        customer?.userName = custumer_name
        order.customer = customer
        
        let from = Address()
        from.address = from_address_full_addr
        order.from = from
        
        let to = Address()
        to.address = toAddressFullAddress
        order.to = to
        
        let divisionModel = BasicModel()
        divisionModel.name = division
        order.division = divisionModel
        
        let orderTypeModel = OrderType(rawValue: Int(typeId))
        order.orderType = orderTypeModel ?? OrderType.pickup
        
        let zone = Zone()
        zone.name = zoneName
        order.zone = zone
        
        var coreDetails = [Order.Detail]()
        
        if let details = detail?.allObjects as? [CoreSKU] {
            details.forEach { (detail) in
                coreDetails.append(detail.convertToOrderDetailModel())
            }
        }
        order.details = coreDetails
        
        return order
    }
    
    
    
}
