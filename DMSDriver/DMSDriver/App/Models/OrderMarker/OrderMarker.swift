//
//  OrderMarker.swift
//  SRSDriver
//
//  Created by phunguyen on 3/16/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import Foundation
import GoogleMaps

class OrderMarker: GMSMarker {
  var order: Order!
  
  convenience init(_ order: Order) {
    self.init()
    //title = order.storeName
   // position = CLLocationCoordinate2D(latitude: order.lat.doubleValue, longitude: order.lng.doubleValue)
  }
}
