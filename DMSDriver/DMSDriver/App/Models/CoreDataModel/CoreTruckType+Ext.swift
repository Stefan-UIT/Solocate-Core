//
//  CoreTruckType+Ext.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 11/18/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

extension CoreTruckType {
    func setAttribiteFrom(truckType: RentingOrder.RentingOrderDetail.RentingTruckType? = nil)  {
        id = Int16(truckType?.id ?? 0)
        name = truckType?.name
        code = truckType?.cd
        fuelType = truckType?.fuelType
        vol = truckType?.vol
        manufacturer = truckType?.manufacturer
        createdAt = truckType?.createdAt
        createdBy = Int16(truckType?.createdBy ?? 0)
        updatedAt = truckType?.updatedAt
        updatedBy = Int16(truckType?.updatedBy ?? 0)
        
    }
    
    func convertToTruckTypeModel() -> RentingOrder.RentingOrderDetail.RentingTruck? {
        let truckTypeJSON = ["id":id,
                          "name":(name ?? ""),
                          "manufacturer":(manufacturer ?? ""),
                          "code":(code ?? ""),
                          "fuel_type":(fuelType ?? ""),
                          "vol":(vol ?? ""),
                          "created_by":createdBy,
                          "created_at":(createdAt ?? ""),
                          "updated_by":updatedBy,
                          "updated_at":(updatedAt ?? "")] as [String:Any]
        let truckType = RentingOrder.RentingOrderDetail.RentingTruck(JSON: truckTypeJSON)
        return truckType
    }
    
}
