//
//  API+Route.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 11/26/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import ObjectMapper
import CoreLocation
import CoreData

extension BaseAPIService {
    @discardableResult
    func getRoutes(byDate date:String? = nil, callback: @escaping APICallback<ResponseDataListModel<Route>>) -> APIRequest {
        var newDate = date;
        if newDate == nil {
            newDate = Date().toString("MM/dd/yyyy")
        }
        let path = String(format: PATH_REQUEST_URL.GET_ROUTES_BY_DATE.URL,"\(Caches().user?.userInfo?.id ?? 0)", E(newDate))
        return request(method: .GET,
                       path:path,
                       input: APIInput.empty,
                       callback: callback);
    }
    
    @discardableResult
    func getRoutesByCoordinator(byDate date:String = Date().toString("yyyy-MM-dd"),
                                callback: @escaping APICallback<ResponseDataModel<CoordinatorRoute>>) -> APIRequest {
        let path = String(format: PATH_REQUEST_URL.GET_ROUTE_BY_COORDINATOR.URL, date)
        return request(method: .GET,
                       path:path,
                       input: APIInput.empty ,
                       callback: callback);
    }
    
    
    @discardableResult
    func getRouteDetail(route:String, callback: @escaping APICallback<ResponseDataModel<Route>>) -> APIRequest {
        let path = String(format:PATH_REQUEST_URL.GET_ROUTE_DETAIL.URL, route)
        return request(method: .GET,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getPackagesInRoute(_ routeID:String,
                            _ date:String ,
                            callback: @escaping APICallback<ResponseDataModel<PackageModel>>) -> APIRequest {
        let path = String(format:PATH_REQUEST_URL.GET_PACKAGES_IN_ROUTE.URL, routeID, date)
        return request(method: .GET,
                       path: path,
                       input: .empty,
                       callback: callback);
    }

}
