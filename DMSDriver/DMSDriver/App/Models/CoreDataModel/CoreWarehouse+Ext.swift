//
//  CoreWarehouse+Ext.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 9/7/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation

//MARK: CoreWarehouse
extension CoreWarehouse{
    
    func setAttributiteFrom(_ warehouse:WarehouseModel?) {
        id = Int32(warehouse?.id ?? 0)
        latLong = E(warehouse?.latLong)
        latitude =  warehouse?.latitude ?? 0
        longitude = warehouse?.longitude ?? 0
        name = warehouse?.name
    }
    
    func convertToWarehouseModel() -> WarehouseModel {
        let warehouse = WarehouseModel()
        warehouse.id = Int(id)
        warehouse.latLong = latLong
        warehouse.longitude = longitude
        warehouse.latitude = latitude
        warehouse.name = name
        
        return warehouse
    }
}
