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
        var totalDoubleType: Int = 0
        var totalPackages: Int = 0
        var totalCartons:Int = 0
        
        
        init() {
            //
        }
        
        init?(map: Map) {
            
        }
        
        mutating func mapping(map: Map) {
            totalDoubleType <-  map["totalDoubleType"];
            totalPackages <-  map["totalPackages"];
            totalCartons <- map["totalCartons"];
        }
    }
    
    struct PackageDetail: Mappable {
        var total_double_type: Int = 0
        var total_cartons: Int = 0
        var total_packages: Int = 0
        var double_type_complete: Int = 0
        var packages_complete: Int = 0
        var cartons_complete :Int = 0
        var double_type_not_complete:Int = 0
        var cartons_not_complete:Int = 0
        var packages_not_complete:Int = 0
        var case_not_complete: Int = 0
        var pallet_not_complete: Int = 0
        
        init() {
            //
        }
        
        init?(map: Map) {
            
        }
        
        mutating func mapping(map: Map) {
            total_double_type <-  map["total_double_type"];
            total_cartons <-  map["total_cartons"];
            total_packages <-  map["total_packages"];
            double_type_complete <-  map["double_type_complete"];
            packages_complete <-  map["packages_complete"];
            cartons_complete <-  map["cartons_complete"];
            double_type_not_complete <- map["double_type_not_complete"]
            cartons_not_complete <- map["cartons_not_complete"]
            packages_not_complete <- map["packages_not_complete"]
            case_not_complete <- map["case_not_complete"]
            pallet_not_complete <- map["pallet_not_complete"]
        }
    }
   
    
    var delivery: PackageDetail = PackageDetail()
    var back_haul: PackageDetail = PackageDetail()
    var package_on_truck: TruckPackage = TruckPackage()
    

    override init() {
        super.init()
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
