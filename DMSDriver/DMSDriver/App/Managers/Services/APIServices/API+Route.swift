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
    func getDataDashboard(timeData:TimeDataItem, callback: @escaping APICallback<ResponseDataModel<ResponseDataDashboard>>) -> APIRequest {
        let startDate = DateFormatter.filterDate.string(from: timeData.startDate ?? Date())
        let endDate = DateFormatter.filterDate.string(from: timeData.endDate ?? Date())
        let path = String(format: PATH_REQUEST_URL.DASHBOARD.URL,startDate,endDate)
        return request(method: .GET,
                       path:path,
                       input: APIInput.empty,
                       callback: callback);
    }
    @discardableResult
    func getRoutes(filterMode:FilterDataModel, page:Int = 1, callback: @escaping APICallback<ResponseDataModel<ResponseDataListModel<Route>>>) -> APIRequest {
        let startDate = DateFormatter.filterDate.string(from: filterMode.timeData?.startDate ?? Date())
        let endDate = DateFormatter.filterDate.string(from: filterMode.timeData?.endDate ?? Date())
        let status = filterMode.status
        let urlString = PATH_REQUEST_URL.GET_ROUTES_LIST.URL
        var path = String(format: urlString,startDate,endDate)
        if let _statusId = status?.id {
            path = path + "&status_id=\(_statusId)"
        }
//        path = path + "&page=\(page)&limit=10"
        path = path + "&limit=9999"
        return request(method: .GET,
                       path:path,
                       input: APIInput.empty,
                       callback: callback);
    }
    
    @discardableResult
    func getRentingOrders(filterMode:FilterDataModel, page:Int = 1, callback: @escaping APICallback<ResponseDataModel<ResponseDataListModel<RentingOrder>>>) -> APIRequest {
        let startDate = DateFormatter.filterDate.string(from: filterMode.timeData?.startDate ?? Date())
        let endDate = DateFormatter.filterDate.string(from: filterMode.timeData?.endDate ?? Date())
        let status = filterMode.status
        let urlString = PATH_REQUEST_URL.GET_RENTING_ORDERS.URL
        var path = String(format: urlString,startDate,endDate)
        if let _statusId = status?.id {
            path = path + "&renting_order_status_id=\(_statusId)"
        }
        path = path + "&limit=9999"
//        path = path + "&page=\(page)&limit=10"
        return request(method: .GET,
                       path:path,
                       input: APIInput.empty,
                       callback: callback);
    }
    
    @discardableResult
    func getPurchaseOrders(filterMode:FilterDataModel, page:Int = 1, callback: @escaping APICallback<ResponseDataModel<ResponseDataListModel<PurchaseOrder>>>) -> APIRequest {
        let startDate = DateFormatter.displayDateUS.string(from: filterMode.timeData?.startDate ?? Date())
        var endDate = ""
        if filterMode.timeData?.endDate != nil {
            endDate = DateFormatter.displayDateUS.string(from: filterMode.timeData?.endDate ?? Date())
        }
        let status = filterMode.status
        let urlString = PATH_REQUEST_URL.GET_PURCHASE_ORDERS.URL
        var path = String(format: urlString,startDate,endDate)
        if let _statusId = status?.id {
            path = path + "&purchase_status_ids=\(_statusId)"
        }
        path = path + "&page=\(page)&limit=10"
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
    
    @discardableResult
    func updateRouteStatus(route: Route, callback: @escaping APICallback<ResponseDataModel<Route>>) -> APIRequest? {
        let path = String(format:PATH_REQUEST_URL.UPDATE_ROUTE_STATUS.URL,  "\(route.id)","\(route.status?.id ?? 0)")
        //        if ReachabilityManager.isNetworkAvailable {
        return request(method: .PUT,
                       path: path,
                       input: .empty,
                       callback: callback);
        //        } else {
        //            return nil
        //        }
    }
    
}
