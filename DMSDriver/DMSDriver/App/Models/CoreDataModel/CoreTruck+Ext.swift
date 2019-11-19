//
//  CoreTruck+Ext.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 11/18/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

extension CoreTruck {
    func setAttribiteFrom(truck: RentingOrder.RentingOrderDetail.RentingTruck? = nil)  {
        id = Int16(truck?.id ?? 0)
        typeId = Int16(truck?.typeId ?? 0)
        driverId = Int16(truck?.driverId ?? 0)
        maxWeight = Int32(truck?.maxWeight ?? 0)
        selfWeight = Int32(truck?.selfWeight ?? 0)
        maxVol = Int32(truck?.maxVol ?? 0)
        plateNum = truck?.plateNum
        companyId = Int16(truck?.companyId ?? 0)
        createdAt = truck?.createdAt
        updatedAt = truck?.updatedAt
    }
    
    func convertToTruckModel() -> RentingOrder.RentingOrderDetail.RentingTruck? {
        let truckJSON = ["id":id,
                          "type_id":typeId,
                          "driver_id":driverId,
                          "max_weight":maxWeight,
                          "self_weight":selfWeight,
                          "max_vol":maxVol,
                          "plate_number":(plateNum ?? ""),
                          "company_id":companyId,
                          "created_at":(createdAt ?? ""),
                          "updated_at": (updatedAt ?? "")] as [String:Any]
        let truck = RentingOrder.RentingOrderDetail.RentingTruck(JSON: truckJSON)
        return truck
    }
    
}
