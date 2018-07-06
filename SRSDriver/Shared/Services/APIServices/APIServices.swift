//
//  BaseAPI.swift
//  Sel2B_REST
//
//  Created by phunguyen on 6/11/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

public typealias ResponseDictionary = [String: Any]
public typealias ResponseArray = [Any]

public func E(_ val: String?) -> String {
  return (val != nil) ? val! : "";
}


extension BaseAPIService {
  
  //MARK: USER
    @discardableResult
    func login(_ userLogin:UserLoginModel, callback: @escaping APICallback<UserModel>) -> APIRequest {
        return request(method: .POST,
                   path: E(Configs.ServicesConfigs(RESTConstants.LOGIN)),
                   input: .dto(userLogin),
                   callback: callback);
    }
    
    @discardableResult
    func logout(callback: @escaping APICallback<UserModel>) -> APIRequest {
        return request(method: .GET,
                       path: E(Configs.ServicesConfigs(RESTConstants.LOGOUT)),
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func updateNotificationFCMToken(_ fcmToken:String,
                                    callback: @escaping APICallback<ResponseDataModel<EmptyModel>>) -> APIRequest {
        
        let params = [
            "notification_token": fcmToken,
            "device": "2" // iOS : device = 2
        ]
        return request(method: .POST,
                       path: E(Configs.ServicesConfigs(RESTConstants.UPDATE_TOKEN_FCM)),
                       input: .json(params),
                       callback: callback);
    }
    
    @discardableResult
    func getOrders(byDate date:String = Date().toString("yyyy-MM-dd"), callback: @escaping APICallback<Route>) -> APIRequest {
        let params = ["date": date]
        return request(method: .PUT,
                       path: E(Configs.ServicesConfigs(RESTConstants.GET_ORDER_BY_DATE)),
                       input: .json(params),
                       callback: callback);
    }
    
    @discardableResult
    func getRoutes(byDate date:String? = nil, callback: @escaping APICallback<ResponseDataListModel<Route>>) -> APIRequest {
        var newDate = date;
        if newDate == nil {
            newDate = Date().toString("yyyy-MM-dd")
        }
        let params = ["date": newDate]
        return request(method: .PUT,
                       path: E(Configs.ServicesConfigs(RESTConstants.GET_ORDER_BY_DATE)),
                       input: .json(params),
                       callback: callback);
    }
    
    @discardableResult
    func getRouteDetail(route:String, callback: @escaping APICallback<Route>) -> APIRequest {
        let path = String(format:E(Configs.ServicesConfigs(RESTConstants.GET_ROUTE_DETAIL)), route)
        return request(method: .GET,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
    
    
    @discardableResult
    func updateOrderStatus(_ order:OrderDetail,reason: Reason? = nil, callback: @escaping APICallback<Route>) -> APIRequest {
        
        let path = String(format:E(RESTConstants.ServicesConfigs[RESTConstants.UPDATE_ORDER_STATUS]), "\(order.id)", order.statusCode)
        
        var params = ["route_id": "\(order.routeId)"]
        if let _reason = reason {
            params["reason_msg"] = _reason.reasonDescription
            params["reason_id"] = "\(_reason.id)"
        }
        return request(method: .PUT,
                       path: path,
                       input: .json(params),
                       callback: callback);
    }
    
    
    @discardableResult
    func getOrderDetail(orderId:String, callback: @escaping APICallback<OrderDetail>) -> APIRequest {
        let uri = String(format:E(Configs.ServicesConfigs(RESTConstants.GET_ORDER_DETAIL)), orderId)
        return request(method: .GET,
                       path: uri,
                       input: .empty,
                       callback: callback);
    }
  
    @discardableResult
    func submitSignature(_ file:AttachFileModel,_ orderId:String, callback: @escaping APICallback<AttachFileModel>) -> APIRequest {
        let uri = String(format:E(Configs.ServicesConfigs(RESTConstants.UPLOAD_SIGNATURE)), orderId)
        let headers = ["Content-Type":"multipart/form-data; boundary=\(E(file.boundary))"];

        return request(method: .POST,
                   headers:headers,
                   path: uri,
                   input: .dto(file),
                   callback: callback);
    }
    
    @discardableResult
    func updateDriverLocation(long :Double, lat:Double, callback: @escaping APICallback<Route>) -> APIRequest {
        let path = String(format:E(RESTConstants.ServicesConfigs[RESTConstants.UPDATE_DRIVER_LOCATION]))
        let driverID = Caches().user?.userID ?? -1
        let timestamps = Date().timeIntervalSince1970
        let params = [
            KEY_LONGITUDE: long,
            KEY_LATITUDE : lat,
            KEY_TIMESTAMPS: timestamps,
            KEY_DRIVER_ID: driverID
            ] as [String : Any]
        
        return request(method: .POST,
                       path: path,
                       input: .json(params),
                       callback: callback);
    }
    
    @discardableResult
    func getUserProfile(callback: @escaping APICallback<ResponseDataModel<UserModel>>) -> APIRequest {
        let path = String(format:E(RESTConstants.ServicesConfigs[RESTConstants.GET_USER_PROFILE]))
        return request(method: .GET,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
  
  @discardableResult
  func updateUserProfile(_ user:UserModel, callback: @escaping APICallback<ResponseDataModel<UserModel>>) -> APIRequest {
    let path = String(format:E(RESTConstants.ServicesConfigs[RESTConstants.UPDATE_USER_PROFILE]))
    return request(method: .PUT,
                   path: path,
                   input: .dto(user),
                   callback: callback);
  }
    
  
  /*
  
  //MARK: - COMPANY
  @discardableResult
  public  func getCompanyInfo(callback: @escaping APICallback<ProductResultsModel>) -> APIRequest {
    return request( method: .GET,
                    path: .companyInfo,
                    input: .empty,
                    callback: callback);
  }
  
  
  //MARK: - PRODUCT
  @discardableResult
  func getListProduct(queryString query:String, callback: @escaping APICallback<ProductResultsModel>) -> APIRequest {
    return request( method: .GET,
                    path: .listProduct(query),
                    input: .empty,
                    callback: callback);
  }
  
  @discardableResult
  func getListProductCategories(callback: @escaping APICallback<ProductCategoryResultsModel>) -> APIRequest {
    return request( method: .GET,
                    path: .listCategories,
                    input: .empty,
                    callback: callback);
  }
  
  //MARK: - ORDER
  @discardableResult
  public func getOrderList(queryString query:String, callback: @escaping APICallback<ListOrderResultsModel>) -> APIRequest {
    return request( method: .GET,
                    path: .listOrder(query),
                    input: .empty,
                    callback: callback);
  }
  
  @discardableResult
  public func getOrderStatus(callback: @escaping APICallback<ListModel<OrderStatus>>) -> APIRequest {
    return request( method: .GET,
                    path: .listOrderStatus,
                    input: .empty,
                    callback: callback);
  }
  
  @discardableResult
  public func getOrderReport(callback: @escaping APICallback<ListModel<ReportOrder>>) -> APIRequest {
    return request( method: .GET,
                    path: .reportOrders,
                    input: .empty,
                    callback: callback);
  }
  
  @discardableResult
  public func getOrderDetail(orderId:String, callback: @escaping APICallback<OrderDetailModel>) -> APIRequest {
    return request( method: .GET,
                    path: .orderDetail(orderId),
                    input: .empty,
                    callback: callback);
  }
  
  @discardableResult
  public func createOrder(params:JSONData, callback: @escaping APICallback<OrderDetailModel>) -> APIRequest {
    return request( method: .POST,
                    path: .createOrder,
                    input: .json(params),
                    callback: callback);
  }
  
  
  //MARK: CUSTOMER
  @discardableResult
  public func getListCustomer(callback: @escaping APICallback<ListCustomerResultsModel>) -> APIRequest {
    return request( method: .GET,
                    path: .listCustomer,
                    input: .empty,
                    callback: callback);
  }
  
  @discardableResult
  public func getCustomerInfo(customerId:String, callback: @escaping APICallback<CustomerDetailModel>) -> APIRequest {
    return request( method: .GET,
                    path: .customerInfo(customerId),
                    input: .empty,
                    callback: callback);
  }
  
  @discardableResult
  public func getProductReference(callback: @escaping APICallback<ProductSearchConditionResultsModel>) -> APIRequest {
    return request( method: .GET,
                    path: .productReferenceData,
                    input: .empty,
                    callback: callback);
  }
  
  
  
  

  //MARK: - FILES
  
  // Solution 1
  @discardableResult
  func uploadFile(file:AttachFileModel, orderId:String, callback: @escaping APICallback<AttachFileModel>) -> APIRequest {
    
    let headers = ["Content-Type":"multipart/form-data; boundary=\(E(file.boundary))"];
    
    //E(ConstantsRequest.configs[ConstantsRequest.BASE_URL_FILE]
    return request(method: .POST,
                   serverURL: RESTConstants.baseURLUploadFile.uri,
                   headers:headers,
                   path: .addFile(orderId),
                   input: .dto(file),
                   callback: callback);
  }
  
  // Solution 2, upload mutifile
  @discardableResult
  func uploadFiles(files:[AttachFileModel],orderId:String, callback: @escaping APICallback<AttachFileModel>) -> APIRequest {
    
    let headers = ["Content-Type":"multipart/form-data; boundary=\(E(files.first?.boundary))"];
    
    //Curently can't test with Sel2B server File
    //E(ConstantsRequest.configs[ConstantsRequest.BASE_URL_FILE]
    return request(method: .POST,
                   serverURL: RESTConstants.baseURLUploadFile.uri,
                   headers:headers,
                   path: .addFile(orderId),
                   input: .mutiFile(files),
                   callback: callback);
  }
  
  
  // Solution 3, upload mutifile
  func uploadFiles(files:[AttachFileModel],orderId:String, callback: @escaping APICallback<UploadFileResponse>) {
    
    let headers = ["Content-Type":"multipart/form-data; boundary=\(E(files.first?.boundary))"];
    //let server = E(ConstantsRequest.configs[ConstantsRequest.BASE_URL_FILE]
    
    //Curently can't test with Sel2B server File
    let server = "https://apigw.seldatdirect.com/staging/sdms/api/backend-api/v1/" //test
    
    uploadMultipartFormData(method: .POST,
                            serverURL:server,
                            headers: headers,
                            path: .addFile(orderId),
                            input: files,
                            callback: callback)
  }
*/
}
