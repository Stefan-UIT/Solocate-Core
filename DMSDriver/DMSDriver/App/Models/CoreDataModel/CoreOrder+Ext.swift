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
        //
        orderFile?.addingObjects(from: order.files ?? [])
        
        // Pick up
        pickupContactName = order.from?.name
        pickupContactPhone = order.from?.phone
        pickupLocationName = order.from?.loc_name
        pickupFloor = order.from?.floor
        pickupApt = order.from?.apartment
        pickupNumber = order.from?.number
        pickupStartTime = order.from?.start_time
        pickupEndTime = order.from?.end_time
        pickupService = Int32(order.from?.srvc_time ?? 0)
        
        // Delivery
        deliveryContactName = order.to?.name
        deliveryContactPhone = order.to?.phone
        deliveryLocationName = order.to?.loc_name
        deliveryFloor = order.to?.floor
        deliveryApt = order.to?.apartment
        deliveryNumber = order.to?.number
        deliveryStartTime = order.to?.start_time
        deliveryEndTime = order.to?.end_time
        deliveryServiceTime = Int32(order.to?.srvc_time ?? 0)
       
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
        
        // Pick up
        let from = Address()
        from.address = from_address_full_addr
        from.name = pickupContactName
        from.loc_name = pickupContactName
        from.phone = pickupContactPhone
        from.apartment = pickupApt
        from.floor = pickupFloor
        from.number = pickupNumber
        from.start_time = pickupStartTime
        from.end_time = pickupEndTime
        from.srvc_time = Int(pickupService)
        order.from = from
        
        // Delivery
        let to = Address()
        to.address = toAddressFullAddress
        to.name = deliveryContactName
        to.loc_name = deliveryLocationName
        to.phone = deliveryContactPhone
        to.apartment = deliveryApt
        to.floor = deliveryFloor
        to.number = deliveryNumber
        to.start_time = deliveryStartTime
        to.end_time = deliveryEndTime
        to.srvc_time = Int(deliveryServiceTime)
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
        
        var coreFile = [AttachFileModel]()
        if let files = orderFile?.allObjects as? [CoreAttachFile] {
            files.forEach{ (file) in
                coreFile.append(file.convertToAttachfileModel())
            }
        }
        order.files = coreFile

        
        return order
    }
    
    
    
}
