//
//  API+Order.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 11/30/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation

extension BaseAPIService{
    //MARK: - ORDER
    @discardableResult
    func getOrders(byDate date:String = Date().toString("yyyy-MM-dd"), callback: @escaping APICallback<Route>) -> APIRequest {
        let params = ["date": date]
        return request(method: .PUT,
                       path: PATH_REQUEST_URL.GET_ORDER_BY_DATE.URL,
                       input: .json(params),
                       callback: callback);
    }
    
    @discardableResult
    func updateOrderStatus(_ order:Order,
                           reason: Reason? = nil,
                           callback: @escaping APICallback<ResponseDataModel<Order>>) -> APIRequest? {
        
        let path = String(format:PATH_REQUEST_URL.UPDATE_ORDER.URL,
                          "\(order.id)", "\(order.status?.id ?? 0)")
        var params = ["route_id": "\(order.route_id)"]
        if let _reason = reason {
            params["message"] = _reason.message != nil ? _reason.message :  _reason.reasonDescription
            params["reason_id"] = "\(_reason.id)"
        }
        
        if !isEmpty(order.note){
            params["note"] = E(order.note)
        }
        
        if ReachabilityManager.isNetworkAvailable{
            return request(method: .POST,
                           path: path,
                           input: .json(params),
                           callback: callback);
        }else{
            //Save request to local DB
            /*
            let data = parseJson(params)
            let request =  RequestModel.init(ParamsMethod.PUT.rawValue,
                                             E(RESTConstants.getBASEURL()),
                                             path,
                                             data)
            CoreDataManager.saveRequest(request)
             */
            return nil
        }
    }
    
    @discardableResult
    func getReasonList(callback: @escaping APICallback<ResponseDataModel<ResponseArrData<Reason>>>) -> APIRequest {
        return request(method: .GET,
                       path:  PATH_REQUEST_URL.GET_REASON_LIST.URL,
                       input: .empty,
                       callback: callback);
    }
    
    
    @discardableResult
    func getOrderDetail(orderId:String, callback: @escaping APICallback<ResponseDataModel<Order>>) -> APIRequest {
        let uri = String(format:PATH_REQUEST_URL.GET_ORDER_DETAIL.URL , orderId)
        return request(method: .GET,
                       path: uri,
                       input: .empty,
                       callback: callback);
    }
    
    func submitSignature(_ file:AttachFileModel,_ order:Order, callback: @escaping APICallback<Order>) {
        let path = String(format:PATH_REQUEST_URL.UPDATE_ORDER.URL, "\(order.id)","\(order.status?.id ?? 0)")
        let url = E(RESTConstants.getBASEURL()).appending(path)

        //let headers = ["Content-Type":"multipart/form-data; boundary=\(E(file.boundary))"];
        let params = ["route_id": "\(order.route_id)"]
        requestWithFormDataType(url: url,
                                method: .post,
                                files: [file],
                                parameters: params,
                                callback: callback)

        /*
        if ReachabilityManager.isNetworkAvailable {
            return request(method: .POST,
                           headers:headers,
                           path: uri,
                           input: .dto(file),
                           callback: callback);
        }else{
            
            let stringHeader = jsonToString(json: headers as AnyObject)
            let data = file.getJsonObject(method: .POST)
            let request =  RequestModel.init(ParamsMethod.POST.rawValue,
                                             E(RESTConstants.getBASEURL()),
                                             uri,
                                             data as? Data,
                                             stringHeader)
            CoreDataManager.saveRequest(request)
            return nil
        }
         */
    }
    
    
    @discardableResult
    func addNewOrderItem(_ orderID: String, barcode: String, qty: String, callback: @escaping APICallback<ResponseDataModel<EmptyModel>>) -> APIRequest {
        let params = [
            [
                "barcode": barcode,
                "qty": qty
            ]
        ]
        let path = String(format: PATH_REQUEST_URL.ADD_NEW_ORDER_ITEM.URL, orderID)
        return request(method: .POST,
                       path: path,
                       input: .json(params),
                       callback: callback);
    }
    
    @discardableResult
    func uploadImageToOrder(_ orderId:String,_ file:AttachFileModel, callback: @escaping APICallback<AttachFileModel>) -> APIRequest {
        let path = String(format:PATH_REQUEST_URL.UPLOAD_FILES.URL, orderId)
        let headers = ["Content-Type":"multipart/form-data; boundary=\(E(file.boundary))"];
        
        return request(method: .POST,
                       headers:headers,
                       path: path,
                       input: .mutiFile([file]),
                       callback: callback)
        
    }
    
    func uploadMultipleImageToOrder(_ files:[AttachFileModel],_ order:Order, callback: @escaping APICallback<Order>){
        let path = String(format:PATH_REQUEST_URL.UPDATE_ORDER.URL, "\(order.id)","\(order.status?.id ?? 0)")
        let url = E(RESTConstants.getBASEURL()).appending(path)
        let params = ["route_id": "\(order.route_id)"]
        
        if ReachabilityManager.isNetworkAvailable {
      
            requestWithFormDataType(url: url,
                                    method: .post,
                                    files: files,
                                    parameters: params,
                                    callback: callback)
        }else {
            /*
            let stringHeader = jsonToString(json: headers as AnyObject)
            let data = getMutiDataFromFile(files: files)
            let request =  RequestModel.init(ParamsMethod.POST.rawValue,
                                             E(RESTConstants.getBASEURL()),
                                             path,
                                             data,
                                             stringHeader)
            CoreDataManager.saveRequest(request)
             */
        }
    }
}
