
//
//  ResponseDataDashboard.swift
//  DMSDriver
//
//  Created by Mach Van  Nguyen on 4/1/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper

class ResponseDataDashboard: BaseModel {
    var routeList:[Route] = []
    var newTasks:[TaskModel] = []
    var newAlerts:[AlertModel] = []
    var lateRoutes:[Route] = []
    var lateOrders:[Order] = []

    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        routeList <- map["route_list"]
        newTasks <- map["new_tasks"]
        newAlerts <- map["new_alerts"]
        lateRoutes <- map["late_routes"]
        lateOrders <- map["late_orders"]
    }
    
    func filterBy(status:Route.RouteStatus) -> [Route] {
        let arr = routeList.filter({ (route) -> Bool in
            return route.routeStatus == status
        })
        return arr
    }
}
