//
//  CoreTankerType+Ext.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 11/18/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

extension CoreTankerType {
    func setAttribiteFrom(tankerType: RentingOrder.RentingOrderDetail.RentingTruckType? = nil)  {
        id = Int16(tankerType?.id ?? 0)
        name = tankerType?.name
        maxVol = tankerType?.maxVol
        numOfCompartments = Int32(tankerType?.numberOfCompartments ?? 0)
        tachograph = Int32(tankerType?.tachograph ?? 0)
        companyId = Int16(tankerType?.companyId ?? 0)
        createdAt = tankerType?.createdAt
        createdBy = Int16(tankerType?.createdBy ?? 0)
        updatedAt = tankerType?.updatedAt
        updatedBy = Int16(tankerType?.updatedBy ?? 0)
        
    }
    
    func convertToTankerTypeModel() -> RentingOrder.RentingOrderDetail.RentingTruckType? {
        let tankerTypeJSON = ["id":id,
                          "name":(name ?? ""),
                          "max_vol":(maxVol ?? ""),
                          "num_of_compartments":numOfCompartments,
                          "company_id":companyId,
                          "created_by":createdBy,
                          "created_at":(createdAt ?? ""),
                          "updated_by":updatedBy,
                          "updated_at":(updatedAt ?? "")] as [String:Any]
        let tankerType = RentingOrder.RentingOrderDetail.RentingTruckType(JSON: tankerTypeJSON)
        return tankerType
    }
    
}
