//
//  CoreCoordinatorRoute.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 9/7/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation

//MARK: CoreOrder
extension CoreCoordinatorRoute{
    
    func setAttributeFrom(_ coordinatorRoute:CoordinatorRoute) {
        date = coordinatorRoute.date
        id = Int32(coordinatorRoute.id)
    }
    
    func convertToCoordinatorRoute() -> CoordinatorRoute {
        let coordinatorRoute = CoordinatorRoute()
        guard let routeFordriver = drivers?.allObjects as? [CoreRoute] else {
            return coordinatorRoute
        }
        
        routeFordriver.forEach { (coreRoute) in
            coordinatorRoute.drivers?.append(coreRoute.convertToRoute())
        }
        
        guard let routeForCoordinator = coordinator?.allObjects as? [CoreRoute] else {
            return coordinatorRoute
        }
        
        routeForCoordinator.forEach { (coreRoute) in
            coordinatorRoute.coordinator?.append(coreRoute.convertToRoute())
        }
        
        coordinatorRoute.drivers = coordinatorRoute.drivers?.sorted { (route1, route2) -> Bool in
            return route1.id > route2.id
        }
        
        coordinatorRoute.coordinator = coordinatorRoute.coordinator?.sorted { (route1, route2) -> Bool in
            return route1.id > route2.id
        }
        
        return coordinatorRoute
    }
}
