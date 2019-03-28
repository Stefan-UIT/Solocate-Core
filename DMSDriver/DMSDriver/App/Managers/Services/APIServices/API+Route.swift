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
    func getRoutes(filterMode:FilterDataModel, callback: @escaping APICallback<ResponseDataListModel<Route>>) -> APIRequest {
        let startDate = DateFormatter.filterDate.string(from: filterMode.startDate ?? Date())
        let endDate = DateFormatter.filterDate.string(from: filterMode.endDate ?? Date())

        let path = String(format: PATH_REQUEST_URL.GET_ROUTES_BY_DATE.URL,startDate,endDate)
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
    
    @discardableResult
    func startRoute(_ routeID:String,
                    callback: @escaping APICallback<ResponseDataModel<PackageModel>>) -> APIRequest {
        let path = String(format:PATH_REQUEST_URL.START_ROUTE.URL, routeID)
        return request(method: .PUT,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getAllRouteInprogess(callback: @escaping APICallback<DataAny>) -> APIRequest {
        return request(method: .GET,
                       path: PATH_REQUEST_URL.GET_ALL_ROUTE_INPROGESS.URL,
                       input: .empty,
                       callback: callback);
    }
    
}
