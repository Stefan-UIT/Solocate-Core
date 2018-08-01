//
//  Route.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper
import GoogleMaps

class Route: BaseModel {
  
  var id = -1
  var truckID = -1
  var driverID = -1
  var totalOrders = -1
  var totalDistance = -1
  var totalZip = -1
  var totalVolume = ""
  var totalWeight = ""
  var truckFloorCap = ""
  var date = ""
  var capacityUsage = ""
  var status = ""
  var orderList = [Order]()
  var pickupList = [PickupPlace]()
  var messages = [Message]()
  var currentItems = [OrderItem]()
  var warehouse:WarehouseModel!
  var endDate = ""
  var startDate = ""
    
  var start_time = ""
  var end_time = ""
  var driver_name = ""

    
  var route_number = 0
  var route_name_sts = ""
    var colorStatus:UIColor {
        get{
            
            switch status {
            case "OP":
                return AppColor.newStatus;
            case "IP":
                return AppColor.inProcessStatus;
            case "DV":
                return AppColor.deliveryStatus;
            default:
                return AppColor.white;
            }
            
        }
    }

  
  convenience required init?(map: Map) {
    self.init()
  }
  
    override func mapping(map: Map) {
    id          <- map["route_id"]
    truckID     <- map["truck_id"]
    driverID    <- map["driver_id"]
    totalOrders <- map["tot_orders"]
    totalDistance <- map["tot_dist"]
    totalZip    <- map["tot_zip"]
    totalVolume <- map["tot_vol"]
    totalWeight <- map["tot_weight"]
    truckFloorCap <- map["truck_floor_cap"]
    date        <- map["date"]
    capacityUsage <- map["capacity_usage"]
    status      <- map["route_sts"]
    orderList   <- map["order_list"]
    pickupList  <- map["pickup_list"]
    messages    <- map["messages"]
    currentItems <- map["current_item"]
    route_number <- map["route_number"]
    route_name_sts <- map["route_name_sts"]
    warehouse <- map[KEY_WARE_HOUSE]
    start_time <- map["start_time"]
    driver_name <- map["driver_name"]
    end_time <- map["end_time"]

  }
    
    func arrayOrderMarkersFromOrderList() -> [OrderMarker] {
        var array = [OrderMarker]()
        for order in orderList {
            let orderMarker = OrderMarker.init(order)
            array.append(orderMarker)
        }
        return array
    }
    
    func distinctArrayOrderList() -> [Order] {
        //temp function
        var addedArray = [Order]()
        for index in orderList {
            var repeatedCount = 0
            orderList.forEach{
                if $0.locationID == index.locationID {
                    repeatedCount += 1
                }
            }
            if repeatedCount > 1 {
                let array = addedArray.filter({$0.locationID == index.locationID})
                if array.count > 0 {
                    continue
                }
            }
            addedArray.append(index)
        }
        
        return addedArray
    }
}


