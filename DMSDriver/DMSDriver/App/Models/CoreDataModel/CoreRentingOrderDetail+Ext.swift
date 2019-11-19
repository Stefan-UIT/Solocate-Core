//
//  CoreRentingOrderDetail+Ext.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 11/18/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation
import CoreData


extension CoreRentingOrderDetail {
    func setAttributeFrom(_ rentingOrder:RentingOrder.RentingOrderDetail, context: NSManagedObjectContext)  {
        id = Int16(rentingOrder.id )
        let _truck = rentingOrder.truck?.toCoreTruck(context: context)
        truck = _truck
        let _truckType = rentingOrder.truckType?.toCoreTruckType(context: context)
        truckType = _truckType
        sku?.addingObjects(from: rentingOrder.sku ?? [])
        
        let _driver = rentingOrder.driver?.toCoreUserInfo(context: context)
        driver = _driver
        
        tankers?.addingObjects(from: rentingOrder.tanker?.tankers ?? [])
        tankerType?.addingObjects(from: rentingOrder.tanker?.tankerType ?? [])
        
    }
    
    func convertToRentingOrder() -> RentingOrder.RentingOrderDetail {
        let rentingOrderDetail = RentingOrder.RentingOrderDetail()
        rentingOrderDetail.id = Int(id)
        rentingOrderDetail.truck = truck?.convertToTruckModel()
        rentingOrderDetail.truckType = truckType?.convertToTruckTypeModel()
        rentingOrderDetail.driver = driver?.convertToUserInfoModel()
        
        var _sku = [RentingOrder.RentingOrderSKU]()
        if let sku = sku?.allObjects as? [CoreSKU] {
            sku.forEach { (eachSKU) in
                _sku.append(eachSKU.convertToRentingOrderSKUModel())
            }
        }
        rentingOrderDetail.sku = _sku
        
        var _tankers = [RentingOrder.RentingOrderDetail.RentingTruck]()
        if let tankers = tankers?.allObjects as? [CoreTanker] {
            tankers.forEach{ (tanker) in
                _tankers.append(tanker.convertToTankerModel()!)
            }
        }
        
        var _tankerType = [RentingOrder.RentingOrderDetail.RentingTruckType]()
        if let tankerType = tankerType?.allObjects as? [CoreTankerType] {
            tankerType.forEach{ (tankerType) in
                _tankerType.append(tankerType.convertToTankerTypeModel()!)
            }
        }
        
        let params:[String:Any]! = [
            "tankers" : _tankers.toJSON(),
            "tanker_type": _tankerType.toJSON()
        ]
        
        rentingOrderDetail.tanker = RentingOrder.RentingOrderDetail.RentingTanker(JSON: params)
        
        return rentingOrderDetail
    }
    
}
