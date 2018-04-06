//
//  Route.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class Route: NSObject, Mappable {
  
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
  var endDate = ""
  var startDate = ""
  
  convenience required init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
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
  }
}


