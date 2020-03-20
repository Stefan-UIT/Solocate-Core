//
//  API+Business.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/19/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import Foundation

extension BaseAPIService {
    @discardableResult
    func getBusinessOrders(filterMode:FilterDataModel, page:Int = 1, callback: @escaping APICallback<ResponseDataModel<ResponseDataListModel<BusinessOrder>>>) -> APIRequest {
        let startDate = DateFormatter.displayDateUS.string(from: filterMode.timeData?.startDate ?? Date())
        var endDate = ""
        if filterMode.timeData?.endDate != nil {
            endDate = DateFormatter.displayDateUS.string(from: filterMode.timeData?.endDate ?? Date())
        }
        let status = filterMode.status
        let urlString = PATH_REQUEST_URL.GET_BUSINESS_ORDERS.URL
        var path = String(format: urlString,startDate,endDate)
        if let _statusId = status?.id {
            path = path + "&business_status_ids=\(_statusId)"
        }
        path = path + "&page=\(page)&limit=10"
        return request(method: .GET,
                       path:path,
                       input: APIInput.empty,
                       callback: callback);
    }
    
    @discardableResult
    func getBusinessOrderDetail(orderId:String, callback: @escaping APICallback<ResponseDataModel<BusinessOrder>>) -> APIRequest {
        let url = String(format:PATH_REQUEST_URL.GET_BUSINESS_ORDER_DETAIL.URL , orderId)
        return request(method: .GET,
                       path: url,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getCustomerList(orderId:Int,_ isWarehouse:Bool? = true, callback: @escaping APICallback<ResponseDataListModel<CustomerModel>>) -> APIRequest {
//        let code = isWarehouse ? "WH" : "CS"
        let url = String(format:PATH_REQUEST_URL.GET_CUSTOMER_LIST.URL , orderId, "WH")
        return request(method: .GET,
                       path: url,
                       input: .empty,
                       callback: callback);
    }

    @discardableResult
    func getSKUList(callback: @escaping APICallback<ResponseArrData<Reason>>) -> APIRequest {
        return request(method: .GET,
                       path:  PATH_REQUEST_URL.GET_REASON_LIST.URL,
                       input: .empty,
                       callback: callback);
    }
    
}
