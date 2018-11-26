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
        cartons = Int32(order.cartons)
        cases =  Int32(order.cases)
        client_name =  order.client_name
        collectionCall = order.collectionCall
        created_at = order.created_at
        custumer_name = order.custumer_name
        deliveryAdd = order.deliveryAdd
        deliveryDate = order.deliveryDate
        doubleType =  Int32(order.doubleType)
        driver_id = Int16(order.driver_id)
        driver_name = order.driver_name
        endTime = order.endTime
        from_address_full_addr = order.from_address_full_addr
        from_address_lattd = order.from_address_lattd
        from_address_lngtd = order.from_address_lngtd
        from_loc_id =  Int16(order.from_loc_id)
        id =  Int16(order.id)
        instructions  = order.instructions
        lat = order.lat
        lng = order.lng
        location_full_addr = order.location_full_addr
        location_name = order.location_name
        locationID = Int16(locationID)
        order_status = order.order_status
        order_type_name = order.order_type_name
        order_type_name_hb = order.order_type_name_hb
        orderReference = order.orderReference
        orderType  = order.orderType
        orderTypeId = Int32(order.orderTypeId)
        orderTypeName = order.orderTypeName
        packages =  Int32(order.packages)
        pallets =  Int32(order.pallets)
        pickupContactEmail = order.pickupContactEmail
        pickupContactName = order.pickupContactName
        pickupContactPhone = order.pickupContactPhone
        pod = Int16(order.pod)
        reason_msg =  order.reason_msg
        receiveName = order.receiveName
        receiverPhone = order.receiverPhone
        routeId = Int32(order.routeId)
        secoundReceiveName = order.secoundReceiveName
        seq = Int32(order.seq)
        sequence = Int32(order.sequence)
        shop = order.shop
        shopID = Int16(order.shopID)
        sign = Int16(order.sign)
        standby = Int32(order.standby)
        startTime = order.startTime
        statusCode = order.statusCode
        statusName = order.statusName
        storeName = order.storeName
        supervisor_Id = Int32(order.supervisor_Id)
        supervisor_name = order.supervisor_name
        timeWindowName = order.timeWindowName
        to_address_lattd = order.to_address_lattd
        to_address_lngtd = order.to_address_lngtd
        to_loc_id = Int32(order.to_loc_id)
        toAddressFullAddress = order.toAddressFullAddress
        truck_name = order.truck_name
        urgent = Int32(order.urgent)
        urgent_type_id = Int32(order.urgent_type_id)
        urgent_type_name_en = order.urgent_type_name_en
        urgent_type_name_hb = order.urgent_type_name_hb
        needUpdateToServer = order.needUpdateToServer
        
    }
    
    func setAttribiteFrom(_ order:OrderDetail) {
        cartons = Int32(order.cartons)
        cases =  Int32(order.cases)
        client_name =  order.client_name
        collectionCall = order.collectionCall
        created_at = order.created_at
        custumer_name = order.custumer_name
        deliveryAdd = order.deliveryAdd
        deliveryDate = order.deliveryDate
        doubleType =  Int32(order.doubleType)
        driver_id = Int16(order.driver_id)
        driver_name = order.driver_name
        endTime = order.endTime
        from_address_full_addr = order.from_address_full_addr
        from_address_lattd = order.from_address_lattd
        from_address_lngtd = order.from_address_lngtd
        from_loc_id =  Int16(order.from_loc_id)
        id =  Int16(order.id)
        instructions  = order.instructions
        lat = order.lat
        lng = order.lng
        location_full_addr = order.location_full_addr
        location_name = order.location_name
        locationID = Int16(locationID)
        order_status = order.order_status
        order_type_name = order.order_type_name
        order_type_name_hb = order.order_type_name_hb
        orderReference = order.orderReference
        orderType  = order.orderType
        orderTypeId = Int32(order.orderTypeId)
        orderTypeName = order.orderTypeName
        packages =  Int32(order.packages)
        pallets =  Int32(order.pallets)
        pickupContactEmail = order.pickupContactEmail
        pickupContactName = order.pickupContactName
        pickupContactPhone = order.pickupContactPhone
        pod = Int16(order.pod)
        reason_msg =  order.reason_msg
        receiveName = order.receiveName
        receiverPhone = order.receiverPhone
        routeId = Int32(order.routeId)
        secoundReceiveName = order.secoundReceiveName
        seq = Int32(order.seq)
        sequence = Int32(order.sequence)
        shop = order.shop
        shopID = Int16(order.shopID)
        sign = Int16(order.sign)
        standby = Int32(order.standby)
        startTime = order.startTime
        statusCode = order.statusCode
        statusName = order.statusName
        storeName = order.storeName
        supervisor_Id = Int32(order.supervisor_Id)
        supervisor_name = order.supervisor_name
        timeWindowName = order.timeWindowName
        to_address_lattd = order.to_address_lattd
        to_address_lngtd = order.to_address_lngtd
        to_loc_id = Int32(order.to_loc_id)
        toAddressFullAddress = order.toAddressFullAddress
        truck_name = order.truck_name
        urgent = Int32(order.urgent)
        urgent_type_id = Int32(order.urgent_type_id)
        urgent_type_name_en = order.urgent_type_name_en
        urgent_type_name_hb = order.urgent_type_name_hb
        needUpdateToServer = order.needUpdateToServer
        full_addr = order.full_addr
        
    }
    
    func converToOrder() -> Order {
        let order = Order()
        
        order.cartons = Int(cartons)
        order.cases = Int(cases)
        order.client_name = E(client_name)
        order.collectionCall = E(collectionCall)
        order.created_at = E(created_at)
        order.custumer_name = E(custumer_name)
        order.deliveryAdd = E(deliveryAdd)
        order.deliveryDate = E(deliveryDate)
        order.doubleType = Int(doubleType)
        order.driver_id =  Int(driver_id)
        order.driver_name = E(driver_name)
        order.endTime = E(endTime)
        order.from_address_full_addr = E(from_address_full_addr)
        order.from_address_lattd = E(from_address_lattd)
        order.from_address_lngtd =  E(from_address_lngtd)
        order.from_loc_id = Int(from_loc_id)
        order.id =  Int(id)
        order.instructions = E(instructions)
        order.lat = E(lat)
        order.lng = E(lng)
        order.location_full_addr = E(location_full_addr)
        order.location_name = E(location_name)
        order.locationID = Int(locationID)
        order.order_status =  E(order_status)
        order.order_type_name = E(order_type_name)
        order.order_type_name_hb = E(order_type_name_hb)
        order.orderReference = E(orderReference)
        order.orderType = E(orderType)
        order.orderTypeId = Int(orderTypeId)
        order.orderTypeName = E(orderTypeName)
        order.packages = Int(packages)
        order.pallets = Int(pallets)
        order.pickupContactEmail = E(pickupContactEmail)
        order.pickupContactName = E(pickupContactName)
        order.pickupContactPhone = E(pickupContactPhone)
        order.pod = Int(pod)
        order.reason_msg = E(reason_msg)
        order.receiveName  = E(receiveName)
        order.receiverPhone = E(receiverPhone)
        order.routeId = Int(routeId)
        order.secoundReceiveName  = E(secoundReceiveName)
        order.seq = Int(seq)
        order.sequence = Int(sequence)
        order.shop = E(shop)
        order.shopID = Int(shopID)
        order.sign = Int(sign)
        order.standby = Int(standby)
        order.startTime = E(startTime)
        order.statusCode = E(statusCode)
        order.statusName = E(statusName)
        order.storeName = E(storeName)
        order.supervisor_Id = Int(supervisor_Id)
        order.supervisor_name = E(supervisor_name)
        order.timeWindowName = E(timeWindowName)
        order.to_address_lattd = E(to_address_lattd)
        order.to_address_lngtd = E(to_address_lngtd)
        order.to_loc_id = Int(to_loc_id)
        order.toAddressFullAddress = E(toAddressFullAddress)
        order.truck_name = E(truck_name)
        order.urgent = Int(urgent)
        order.urgent_type_id = Int(urgent_type_id)
        order.urgent_type_name_en = E(urgent_type_name_en)
        order.urgent_type_name_hb = E(urgent_type_name_hb)
        order.needUpdateToServer = needUpdateToServer
        order.full_addr = full_addr
        
        return order
    }
    
    func converToOrderDetail() -> OrderDetail {
        let order = OrderDetail()
        
        order.cartons = Int(cartons)
        order.cases = Int(cases)
        order.client_name = E(client_name)
        order.collectionCall = E(collectionCall)
        order.created_at = E(created_at)
        order.custumer_name = E(custumer_name)
        order.deliveryAdd = E(deliveryAdd)
        order.deliveryDate = E(deliveryDate)
        order.doubleType = Int(doubleType)
        order.driver_id =  Int(driver_id)
        order.driver_name = E(driver_name)
        order.endTime = E(endTime)
        order.from_address_full_addr = E(from_address_full_addr)
        order.from_address_lattd = E(from_address_lattd)
        order.from_address_lngtd =  E(from_address_lngtd)
        order.from_loc_id = Int(from_loc_id)
        order.id =  Int(id)
        order.instructions = E(instructions)
        order.lat = E(lat)
        order.lng = E(lng)
        order.location_full_addr = E(location_full_addr)
        order.location_name = E(location_name)
        order.locationID = Int(locationID)
        order.order_status =  E(order_status)
        order.order_type_name = E(order_type_name)
        order.order_type_name_hb = E(order_type_name_hb)
        order.orderReference = E(orderReference)
        order.orderType = E(orderType)
        order.orderTypeId = Int(orderTypeId)
        order.orderTypeName = E(orderTypeName)
        order.packages = Int(packages)
        order.pallets = Int(pallets)
        order.pickupContactEmail = E(pickupContactEmail)
        order.pickupContactName = E(pickupContactName)
        order.pickupContactPhone = E(pickupContactPhone)
        order.pod = Int(pod)
        order.reason_msg = E(reason_msg)
        order.receiveName  = E(receiveName)
        order.receiverPhone = E(receiverPhone)
        order.routeId = Int(routeId)
        order.secoundReceiveName  = E(secoundReceiveName)
        order.seq = Int(seq)
        order.sequence = Int(sequence)
        order.shop = E(shop)
        order.shopID = Int(shopID)
        order.sign = Int(sign)
        order.standby = Int(standby)
        order.startTime = E(startTime)
        order.statusCode = E(statusCode)
        order.statusName = E(statusName)
        order.storeName = E(storeName)
        order.supervisor_Id = Int(supervisor_Id)
        order.supervisor_name = E(supervisor_name)
        order.timeWindowName = E(timeWindowName)
        order.to_address_lattd = E(to_address_lattd)
        order.to_address_lngtd = E(to_address_lngtd)
        order.to_loc_id = Int(to_loc_id)
        order.toAddressFullAddress = E(toAddressFullAddress)
        order.truck_name = E(truck_name)
        order.urgent = Int(urgent)
        order.urgent_type_id = Int(urgent_type_id)
        order.urgent_type_name_en = E(urgent_type_name_en)
        order.urgent_type_name_hb = E(urgent_type_name_hb)
        order.needUpdateToServer = needUpdateToServer
        order.full_addr = full_addr
        
        order.reason = reason?.convertToReasonOrderCC()
        order.url = url?.convertToUrlFileMoldel()
        
        return order
    }
}
