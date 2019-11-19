//
//  CoreRentingOrder+Ext.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 11/18/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation
import CoreData

extension CoreRentingOrder {
    func setAttribiteFrom(_ rentingOrder:RentingOrder, context: NSManagedObjectContext)  {
        id = Int16(rentingOrder.id)
        companyId = Int16(rentingOrder.companyId)
        createdAt = rentingOrder.createdAt
        updatedAt = rentingOrder.updatedAt
        cusId = Int16(rentingOrder.customerId)
        endTime = rentingOrder.endDate
        startTime = rentingOrder.startDate
        refCode = rentingOrder.referenceCode
        statusCode = rentingOrder.rentingOrderStatus?.code
        statusName = rentingOrder.rentingOrderStatus?.name
        
        let _customerUserInfo = rentingOrder.rentingOrderCustomer?.toCoreUserInfo(context: context)
        customer = _customerUserInfo
        
        details?.addingObjects(from: rentingOrder.rentingOrderDetails ?? [])
    }
    
    func convertToRentingOrder() -> RentingOrder {
        let rentingOrder = RentingOrder()
        rentingOrder.id = Int(id)
        rentingOrder.companyId = Int(companyId)
        rentingOrder.createdAt = createdAt
        rentingOrder.updatedAt = updatedAt
        rentingOrder.customerId = Int(cusId)
        rentingOrder.endDate = endTime
        rentingOrder.startDate = startTime
        rentingOrder.referenceCode = refCode ?? ""
        
        let rentingStatus = RentingOrderStatus()
        rentingStatus.name = statusName
        rentingStatus.code = statusCode
        rentingOrder.rentingOrderStatus = rentingStatus
        
        rentingOrder.rentingOrderCustomer = customer?.convertToUserInfoModel()
        
        var _details = [RentingOrder.RentingOrderDetail]()
        if let details = details?.allObjects as? [CoreRentingOrderDetail] {
            details.forEach { (detail) in
                _details.append(detail.convertToRentingOrder())
            }
        }
        rentingOrder.rentingOrderDetails = _details
        
        return rentingOrder
    }
    
}
