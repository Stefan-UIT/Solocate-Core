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
        status = String(route.status?.code ?? "")
        route_name_sts =  route.route_name_sts
        totalOrders = Int16(route.totalOrders)
        totalTimeEst = Int64(route.totalTimeEst)
        totalDistance = route.totalDistance
        companyName = route.company?.name
        truckNumber = route.truck?.plateNumber
        trailerTankerName = route.trailerTankerName
//        loadVolume = route.loadVolume
        orderList?.addingObjects(from: route.orderList)
        locationList?.addingObjects(from: route.locationList)
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
        let _routeStatus = Route.RouteStatus(rawValue: E(status)) ?? .New
        let _status = _routeStatus.convertToStatus()
        route.status = _status
        route.route_name_sts = E(route_name_sts)
        route.totalOrders = Int(totalOrders)

        route.totalTimeEst = Int(totalTimeEst)
        route.totalDistance = totalDistance ?? "0"
        
        
        let _company = Company()
        _company.name = E(companyName)
        route.company = _company
        
        let _truck = Truck()
        _truck.plateNumber = E(truckNumber)
        route.truck = _truck
        route.trailerTankerNameCoreData = E(trailerTankerName)
        
//        route.loadVolume = E(loadVolume)
        
        var _orderList = [Order]()
        if  let orderList = orderList?.allObjects as? [CoreOrder] {
            orderList.forEach { (order) in
                _orderList.append(order.converToOrder())
            }
        }
        route.orderList = _orderList.sorted { $0.id < $1.id }
        
        var _locationList = [Address]()
        if let locationList = locationList?.allObjects as? [CoreLocation] {
            locationList.forEach { (location) in
                _locationList.append(location.convertTocLocationModel())
            }
        }
        route.locationList = _locationList.sorted { $0.id < $1.id }
        
        return route
    }
}
