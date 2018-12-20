//
//  APIServices+Alert.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 12/18/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation

extension BaseAPIService {
    
    @discardableResult
    func getListAlerts(alertFilter:AlertFilterModel? = nil,
                       callback: @escaping APICallback<ResponseDataModel<ResponseArrData<AlertModel>>>) ->APIRequest {
        
        var path = PATH_REQUEST_URL.GET_LIST_ALERT.URL + "?driver_name=\(E(Caches().user?.userInfo?.userName))"

        if let sts = alertFilter?.sts {
            path += "&sts=\(sts)"
        }
        
        if let created_day_from = alertFilter?.created_day_from {
            path += "&created_day_from=\(created_day_from)"
        }
        
        if let created_day_to = alertFilter?.created_day_to {
            path += "&created_day_to=\(created_day_to)"
        }
        
        if let sts_name = alertFilter?.sts_name {
            path += "&sort[sts_name]=\(sts_name)"
        }
        
        if let created_day = alertFilter?.created_day {
            path += "&sort[created_day]=\(created_day)"
        }
        
        return request(method: .GET,
                       path: path.encodeURL(),
                       input: APIInput.empty,
                       callback: callback)
    }
    
    @discardableResult
    func getAlertDetail(alertId:Int,
                        callback: @escaping APICallback<ResponseDataModel<AlertModel>>) ->APIRequest {
        
        let path = String(format: PATH_REQUEST_URL.GET_ALERT_DETAIL.URL, "\(alertId)")
        return request(method: .GET,
                       path: path,
                       input: APIInput.empty,
                       callback: callback)
    }
    
    @discardableResult
    func resolveAlert(alertId:Int,
                      comment:String,
                     callback: @escaping APICallback<ResponseDataModel<AlertModel>>) ->APIRequest {
        let body = ["comment":comment]
        let path = String(format: PATH_REQUEST_URL.RESOLVE_ALERT.URL, "\(alertId)")
        return request(method: .PUT,
                       path: path,
                       input: APIInput.json(body),
                       callback: callback)
    }
}
