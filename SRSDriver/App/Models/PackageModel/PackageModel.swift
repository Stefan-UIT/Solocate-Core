//
//  PackageModel.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 7/13/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class PackageModel: BaseModel {
    
    struct TruckPackage: Mappable {
        var totalCase: Int = 0
        var totalPallet: Int = 0
        
        init() {
            //
        }
        
        init?(map: Map) {
            
        }
        
        mutating func mapping(map: Map) {
            totalCase <-  map["totalCase"];
            totalPallet <-  map["totalPallet"];
        }
    }
    
    struct PackageDetail: Mappable {
        var total_case: Int = 0
        var total_pallet: Int = 0
        var case_complete: Int = 0
        var pallet_complete: Int = 0
        var case_not_complete: Int = 0
        var pallet_not_complete: Int = 0
        init() {
            //
        }
        
        init?(map: Map) {
            
        }
        
        mutating func mapping(map: Map) {
            total_case <-  map["total_case"];
            total_pallet <-  map["total_pallet"];
            case_complete <-  map["case_complete"];
            pallet_complete <-  map["pallet_complete"];
            case_not_complete <-  map["case_not_complete"];
            pallet_not_complete <-  map["pallet_not_complete"];
        }
    }
    
    var delivery: PackageDetail = PackageDetail()
    var back_haul: PackageDetail = PackageDetail()
    var package_on_truck: TruckPackage = TruckPackage()
    
    override init() {
        //
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        delivery <- map["delivery"]
        back_haul <- map["back_haul"]
        package_on_truck <-  map["package_on_truck"]
    }
}
