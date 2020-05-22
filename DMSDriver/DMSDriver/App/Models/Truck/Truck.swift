//
//  Driver.swift
//  DMSDriver
//
//  Created by Trung Vo on 7/29/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation
import ObjectMapper

class Compartment:BaseModel {
    
    class Detail:BaseModel {
        struct Package:Mappable {
            var id:Int?
            var name:String?
            var cd:String?
            
            
            init?(map: Map) {
                //
            }
            
            mutating func mapping(map: Map) {
                id <- map["id"]
                name <- map["name"]
                cd <- map["cd"]
            }
        }
        
        struct Pivot:Mappable {
            var id:Int?
            var sku_id:Int?
            var shipping_order_id:Int?
            var unit_id:Int?
            var bcd:String?
            var batch_id:String?
            var qty:Int?
            var deliveredQty:Int?
            var loadedQty:Int?
            var returnedQty:Int?
            var shippingOrder:Order?
            var unit:Order.Detail.Unit?
            
            init?(map: Map) {
                //
            }
            
            mutating func mapping(map: Map) {
                id <- map["id"]
                sku_id <- map["sku_id"]
                shipping_order_id <- map["shipping_order_id"]
                unit_id <- map["unit_id"]
                bcd <- map["bcd"]
                batch_id <- map["batch_id"]
                qty <- map["qty"]
                loadedQty <- map["loaded_qty"]
                deliveredQty <- map["delivered_qty"]
                returnedQty <- map["returned_qty"]
                shippingOrder <- map["shipping_order"]
                unit <- map["unit"]
            }
        }
        
        var id: Int = -1
        var routeTankerId: Int = -1
        var compartmentId: Int = -1
        var shippingOrderId: Int = -1
        var shippingOrderDetailId = -1
        var quantity: Int = -1
        var quantityDisplay:String {
            get {
                guard let unitName = pivot?.unit?.cd else { return "" }
                let result = "\(quantity) " + unitName
                return result
            }
        }
        var color: String = ""
        var routeTankerCompartmentId: Int = -1
        var name: String = ""
        var package:Package?
        var pivot:Pivot?
        var seq:String = ""
        
        override init() {
            super.init()
        }
        
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            id <- map["id"]
            routeTankerId <- map["route_tanker_id"]
            compartmentId <- map["compartment_id"]
            shippingOrderId <- map["shipping_order_id"]
            quantity <- map["qty"]
            color <- map["color"]
            routeTankerCompartmentId <- map["route_tanker_compartment_id"]
            name <- map["name"]
            package <- map["package"]
            pivot <- map["pivot"]
            seq <- map["seq_plt"]
            shippingOrderDetailId <- map["so_detail_id"]
        }
        
        
    }
    
    var id: Int = -1
    var routeTankerId: Int = -1
    var compartmentId: Int = -1
    var seq: Int = -1
    var name:String = ""
    var vol:String = ""
    var volNameDisplay:String {
        get {
            guard let unitName = detail?.first?.pivot?.unit?.cd else { return vol }
            return vol + " " + unitName
        }
    }
    var detail:[Detail]?
    var compartmentName:String? = ""
    var maxNumCompartment:Int? = -1
    
    override init() {
        super.init()
    }
    
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        routeTankerId <- map["route_tanker_id"]
        compartmentId <- map["compartment_id"]
        seq <- map["seq"]
        name <- map["name"]
        vol <- map["vol"]
        detail <- map["compartment_details"]
        compartmentName <- map["compartment_name"]
        maxNumCompartment <- map["max_num_of_pallets_for_compartment"]
    }
}

class Truck:BaseModel {
    
    var id:Int = -1
    var name = "-"
    var plateNumber = "-"
    var maxLoad = 0
    var maxVolume:String?
    var maxVolumeName:String {
        get {
            return Slash(maxVolume) + " " + unitName
        }
    }
    var maxFloor = 0
    var type:TruckType?
    var compartments:[Compartment]?
    
    var unitName:String {
        get {
            guard let unitName = compartments?.first?.detail?.first?.pivot?.unit?.cd else { return "" }
            return unitName
        }
    }
    
    var totalMaxPallets:Int?
    
    override init() {
        super.init()
    }
    
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        maxLoad <- map["max_load"]
//        maxVolume <- map["max_vol"]
        
        var maxVol: Any?
        maxVol <- map["max_vol"]
        
        if maxVol != nil {
            if maxVol is String {
                maxVolume = maxVol as! String
            } else {
                maxVolume = "\(maxVol!)"
            }
        }
        
        maxFloor <- map["max_floor"]
        type <- map["type"]
        plateNumber <- map["plate_number"]
        if plateNumber == "-" {
            plateNumber <- map["plate_num"]
        }
        compartments <- map["compartments"]
        totalMaxPallets <- map["total_max_pallet"]
    }
}
