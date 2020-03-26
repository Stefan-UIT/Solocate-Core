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
        let urlString = PATH_REQUEST_URL.GET_PURCHASE_ORDERS.URL
        var path = String(format: urlString,startDate,endDate)
        if let _statusId = status?.id {
            path = path + "&business_status_ids=\(_statusId)"
        }
        path = path + "&page=\(page)&limit=10&sort[purchase_order_id]=desc&"
        return request(method: .GET,
                       path:path,
                       input: APIInput.empty,
                       callback: callback);
    }
    
    @discardableResult
    func createBusinessOrder(order:BusinessOrder, callback: @escaping APICallback<ResponseDataModel<ResponseDataListModel<BusinessOrder>>>) -> APIRequest {
        
        let path = PATH_REQUEST_URL.CREATE_BUSINESS_ORDER.URL
        let params = order.toJSON()
        return request(method: .POST,
                       path:path,
                       input: .json(params),
                       callback: callback);
    }
    
    @discardableResult
    func getBusinessOrderDetail(orderId:String, callback: @escaping APICallback<ResponseDataModel<BusinessOrder>>) -> APIRequest {
        let url = String(format:PATH_REQUEST_URL.GET_PURCHASE_ORDER_DETAIL.URL , orderId)
        return request(method: .GET,
                       path: url,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getCustomerList(callback: @escaping APICallback<ResponseDataListModel<UserModel.UserInfo>>) -> APIRequest {
        let url = String(format:PATH_REQUEST_URL.GET_CUSTOMER_LIST.URL)
        return request(method: .GET,
                       path: url,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getLocationsList(callback: @escaping APICallback<ResponseDataListModel<Address>>) -> APIRequest {
        let url = String(format:PATH_REQUEST_URL.GET_LOCATION_LIST.URL)
        return request(method: .GET, path: url, input: .empty, callback: callback)
    }

    @discardableResult
    func getSKUList(callback: @escaping APICallback<ResponseDataListModel<SKUModel>>) -> APIRequest {
        let url = String(format:PATH_REQUEST_URL.GET_SKU_LIST.URL)
        return request(method: .GET,
                       path: url,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getUOMList(callback: @escaping APICallback<ResponseDataListModel<UOMModel>>) -> APIRequest {
        let url = String(format:PATH_REQUEST_URL.GET_UOM_LIST.URL)
        return request(method: .GET,
                       path: url,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getZoneList(callback: @escaping APICallback<ResponseDataListModel<Zone>>) -> APIRequest {
        let url = String(format:PATH_REQUEST_URL.GET_ZONE_LIST.URL)
        return request(method: .GET,
                       path: url,
                       input: .empty,
                       callback: callback);
    }
    
}
