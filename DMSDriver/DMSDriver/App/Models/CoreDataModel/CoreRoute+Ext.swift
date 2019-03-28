//
//  CoreRoute+Ext.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 9/7/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreData


//MARK: CoreRoute
extension CoreRoute{

    func setAttribiteFrom(_ route:Route)  {
        id = Int16(route.id)
        truckID = Int16(route.truckId)
        driver_name = route.driver_name
        start_time = route.start_time
        end_time = route.end_time
        date = route.date
        driverID = Int16(route.driverId)
        shop_name = route.shop_name
        status = route.status?.code
        nameStatus = route.nameStatus
        route_name_sts =  route.route_name_sts
        totalOrders = Int16(route.totalOrders)
    }
    
    
    func convertToRoute() -> Route {
        let route = Route()
        route.id = Int(id)
        route.truckId = Int(truckID)
        route.driver_name = E(driver_name)
        route.start_time = E(start_time)
        route.date = E(date)
        route.driverId = Int(driverID)
        route.end_time = E(end_time)
        route.shop_name = E(shop_name)
        route.end_time = E(endDate)
        route.status?.code = E(status)
        route.route_name_sts = E(route_name_sts)
        route.totalOrders = Int(totalOrders)

        if  let orderList = orderList?.allObjects as? [CoreOrder] {
            orderList.forEach { (order) in
                route.orderList.append(order.converToOrder())
            }
        }
        
        return route
    }
}
