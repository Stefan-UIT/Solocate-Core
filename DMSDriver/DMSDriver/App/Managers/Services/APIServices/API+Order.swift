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
    func updateRentingOrderStatus(nextStatus:Int, rentingOrderDetailId:Int, message:String?, callback: @escaping APICallback<ResponseDataModel<RentingOrder>>) -> APIRequest? {
        let path = String(format:PATH_REQUEST_URL.UPDATE_RENTING_ORDER_DETAIL_STATUS.URL, "\(rentingOrderDetailId)")
        let params:[String:Any] = ["renting_order_status_id": nextStatus, "msg": message]
        if ReachabilityManager.isNetworkAvailable {
            return request(method: .PUT,
                           path: path,
                           input: .json(params),
                           callback: callback);
        } else {
            return nil
        }
    }
    
    @discardableResult
    func updateOrderStatus(_ order:Order,
                           reason: Reason? = nil,
                           updateDetailType:Order.Detail.DetailUpdateType = .Deliver,
                           partialDeliveredReasonMsg:String? = nil,
                           callback: @escaping APICallback<ResponseDataModel<Order>>) -> APIRequest? {
        
        let path = String(format:PATH_REQUEST_URL.UPDATE_ORDER_STATUS.URL,
                          "\(order.id)", "\(order.status?.id ?? 0)")
        var params:[String:Any] = ["route_id": "\(order.route_id)"]
        if let _reason = reason {
            params["shipping_msg"] = _reason.message != nil ? _reason.message :  _reason.reasonDescription
            params["reason_fail_id"] = "\(_reason.id)"
        }
        
        if let msg = partialDeliveredReasonMsg {
            params["message"] = msg
        }
        
        if !isEmpty(order.note){
            params["note"] = E(order.note)
        }
        
        if let details = order.details {
            let detailsParam = details.map({$0.jsonDetailUpdateORderStatus(updateType:updateDetailType, orderStatus: order.statusOrder)})
            params["shipping_details"] = detailsParam
        }
        
        if ReachabilityManager.isNetworkAvailable{
            return request(method: .PUT,
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
    func getReasonList(callback: @escaping APICallback<ResponseArrData<Reason>>) -> APIRequest {
        return request(method: .GET,
                       path:  PATH_REQUEST_URL.GET_REASON_LIST.URL,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getReturnReasonList(callback: @escaping APICallback<ResponseArrData<Reason>>) -> APIRequest {
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
    
    @discardableResult
    func getRentingOrderDetail(rentingOrderId:String, callback: @escaping APICallback<ResponseDataModel<RentingOrder>>) -> APIRequest {
        let uri = String(format:PATH_REQUEST_URL.GET_RENTING_ORDER_DETAIL.URL , rentingOrderId)
        return request(method: .GET,
                       path: uri,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getPurchaseOrderDetail(orderId:String, callback: @escaping APICallback<ResponseDataModel<PurchaseOrder>>) -> APIRequest {
        let uri = String(format:PATH_REQUEST_URL.GET_PURCHASE_ORDER_DETAIL.URL , orderId)
        return request(method: .GET,
                       path: uri,
                       input: .empty,
                       callback: callback);
    }

    
    func submitSignature(_ file:AttachFileModel,_ order:Order, _ name:String, callback: @escaping APICallback<Order>) {
//        let path = String(format:PATH_REQUEST_URL.UPDATE_ORDER_STATUS.URL, "\(order.id)","\(order.status?.id ?? 0)")
        let path = String(format:PATH_REQUEST_URL.UPLOAD_FILES.URL, "\(order.id)")
//        let headers = ["Content-Type":"multipart/form-data; boundary=\(E(file.boundary))"];
        let url = E(SDBuildConf.serverUrlString()).appending(path)

        //let headers = ["Content-Type":"multipart/form-data; boundary=\(E(file.boundary))"];
        let params = [
            "route_id": "\(order.route_id)",
            "sig_name":name,
            "type" : "SIG"
        ]
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
//        let path = String(format:PATH_REQUEST_URL.UPDATE_ORDER_STATUS.URL, "\(order.id)","\(order.status?.id ?? 0)")
        let path = String(format:PATH_REQUEST_URL.UPLOAD_FILES.URL, "\(order.id)")
        
        let url = E(SDBuildConf.serverUrlString()).appending(path)
        let params = [
            "route_id": "\(order.route_id)",
            "type":"POD"
        ]
        
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
    
    func updateNoteToRoute(_ routeID:Int, message:String, files:[AttachFileModel]?, callback: @escaping APICallback<Order>){
        let path = PATH_REQUEST_URL.UPDATE_ROUTE_NOTE.URL
        let url = E(SDBuildConf.serverUrlString()).appending(path)
        let params:[String:Any] = ["route_id": routeID, "content":message]
        
        if ReachabilityManager.isNetworkAvailable {
            
            requestWithFormDataType(url: url,
                                    method: .post,
                                    files: files,
                                    parameters: params,
                                    callback: callback)
        }
    }
    
    func updateNoteToOrder(_ orderID:Int, message:String, files:[AttachFileModel]?, callback: @escaping APICallback<Order>){
        let path = String(format:PATH_REQUEST_URL.UPDATE_ORDER_NOTE.URL, "\(orderID)")
//        let url = E(SDBuildConf.serverUrlString()).appending(path)
        let params:[String:Any] = ["order_id": orderID, "content":message]
        
        if ReachabilityManager.isNetworkAvailable {
            
//            requestWithFormDataType(url: url,
//                                    method: .put,
//                                    files: files,
//                                    parameters: params,
//                                    callback: callback)
            _ = request(method: .PUT,
                           path: path,
                           input: .json(params),
                           callback: callback);
        }
    }
    
    func checkMoreLegs(_ orderID: Int, callback: @escaping APICallback<BoolModel>) {
        let path = String(format:PATH_REQUEST_URL.REQUEST_MORE_LEGS.URL, "\(orderID)")
        if ReachabilityManager.isNetworkAvailable {
            _ = request(method: .GET,
                        path: path,
                        input: .empty,
                        callback: callback);
        }
    }
    
    func requestMoreLegs(_ orderID: Int, legs: Int, callback: @escaping APICallback<ResponseDataModel<EmptyModel>>){
        let path = String(format:PATH_REQUEST_URL.GET_MORE_LEGS.URL, "\(orderID)")
        let params:[String:Any] = ["legs": legs]
        if ReachabilityManager.isNetworkAvailable {
            _ = request(method: .PUT,
                        path: path,
                        input: .json(params),
                        callback: callback);
        }
    }
}
