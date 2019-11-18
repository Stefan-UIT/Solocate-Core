//
//  CoreTanker+Ext.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 11/18/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

extension CoreTanker {
    func setAttribiteFrom(tanker: RentingOrder.RentingOrderDetail.RentingTruck? = nil)  {
        id = Int16(tanker?.id ?? 0)
        typeId = Int16(tanker?.typeId ?? 0)
        driverId = Int16(tanker?.driverId ?? 0)
        maxWeight = Int32(tanker?.maxWeight ?? 0)
        selfWeight = Int32(tanker?.selfWeight ?? 0)
        maxVol = Int32(tanker?.maxVol ?? 0)
        plateNum = tanker?.plateNum
        companyId = Int16(tanker?.companyId ?? 0)
        createdAt = tanker?.createdAt
        updatedAt = tanker?.updatedAt
    }
    
    func convertToTankerModel() -> RentingOrder.RentingOrderDetail.RentingTruck? {
        let tankerJSON = ["id":id,
                          "type_id":typeId,
                          "driver_id":driverId,
                          "max_weight":maxWeight,
                          "self_weight":selfWeight,
                          "max_vol":maxVol,
                          "plate_number":(plateNum ?? ""),
                          "company_id":companyId,
                          "created_at":(createdAt ?? ""),
                          "updated_at": (updatedAt ?? "")] as [String:Any]
        let tanker = RentingOrder.RentingOrderDetail.RentingTruck(JSON: tankerJSON)
        return tanker
    }
    
}
