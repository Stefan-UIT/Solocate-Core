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
    func getListAlerts(callback: @escaping APICallback<ResponseDataModel<ResponseArrData<AlertModel>>>) ->APIRequest {
        return request(method: .GET,
                       path: PATH_REQUEST_URL.GET_LIST_ALERT.URL,
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
