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
import CoreLocation


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
                   path: PATH_REQUEST_URL.LOGIN.URL,
                   input: .dto(userLogin),
                   callback: callback);
    }
    
    @discardableResult
    func logout(callback: @escaping APICallback<UserModel>) -> APIRequest {
        return request(method: .GET,
                       path:PATH_REQUEST_URL.LOGOUT.URL,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func forgotPassword(_ email: String, callback: @escaping APICallback<ResponseDataModel<EmptyModel>>) -> APIRequest {
        let params = ["email": email]
        return request(method: .POST,
                       path: PATH_REQUEST_URL.FORGET_PASSWORD.URL ,
                       input: .json(params),
                       callback: callback);
    }
    
    @discardableResult
    func changePassword(_ para: [String: Any], callback: @escaping APICallback<ChangePasswordModel>) -> APIRequest {
        return request(method: .POST,
                       path: PATH_REQUEST_URL.CHANGE_PASSWORD.URL,
                       input: .json(para),
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
                       path: PATH_REQUEST_URL.UPDATE_TOKEN_FCM.URL,
                       input: .json(params),
                       callback: callback);
    }
    
    
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
    func updateOrderStatus(_ order:OrderDetail,reason: Reason? = nil, callback: @escaping APICallback<Route>) -> APIRequest {
        
        let path = String(format:PATH_REQUEST_URL.UPDATE_ORDER_STATUS.URL, "\(order.id)", order.statusCode)
        
        var params = ["route_id": "\(order.routeId)"]
        if let _reason = reason {
            params["reason_msg"] = _reason.message != nil ? _reason.message :  _reason.reasonDescription
            params["reason_id"] = "\(_reason.id)"
        }
        return request(method: .PUT,
                       path: path,
                       input: .json(params),
                       callback: callback);
    }
    
    @discardableResult
    func getReasonList(_ type: String = "1", callback: @escaping APICallback<ResponseDataListModel<Reason>>) -> APIRequest {
        let path = String(format: PATH_REQUEST_URL.GET_REASON_LIST.URL , type)
        
        return request(method: .GET,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
    
    
    @discardableResult
    func getOrderDetail(orderId:String, callback: @escaping APICallback<OrderDetail>) -> APIRequest {
        let uri = String(format:PATH_REQUEST_URL.GET_ORDER_DETAIL.URL , orderId)
        return request(method: .GET,
                       path: uri,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func submitSignature(_ file:AttachFileModel,_ orderId:String, callback: @escaping APICallback<AttachFileModel>) -> APIRequest {
        let uri = String(format:PATH_REQUEST_URL.UPLOAD_SIGNATURE.URL, orderId)
        let headers = ["Content-Type":"multipart/form-data; boundary=\(E(file.boundary))"];
        
        return request(method: .POST,
                       headers:headers,
                       path: uri,
                       input: .dto(file),
                       callback: callback);
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
    
    @discardableResult
    func uploadMultipleImageToOrder(_ orderId:String,_ files:[AttachFileModel], callback: @escaping APICallback<AttachFileModel>) -> APIRequest {
        let path = String(format:PATH_REQUEST_URL.UPLOAD_FILES.URL, orderId)
        let headers = ["Content-Type":"multipart/form-data; boundary=\(E(files.first?.boundary))"];
        
        return request(method: .POST,
                       headers:headers,
                       path: path,
                       input: .mutiFile(files),
                       callback: callback)
        
    }
    
    @discardableResult
    func getDriversByCoordinator(callback: @escaping APICallback<ResponseDataListModel<DriverModel>>) -> APIRequest {
        return request(method: .GET,
                       path: PATH_REQUEST_URL.GET_DRIVER_BY_COORDINATOR.URL,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getOrderByCoordinator(byDate date:String = Date().toString("yyyy-MM-dd"),
                               callback: @escaping APICallback<ResponseDataListModel<Order>>) -> APIRequest {
        let path = String(format: PATH_REQUEST_URL.GET_ORDER_BY_COORDINATOR.URL, date)
        return request(method: .GET,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func assignOrderToDriver(body:RequestAssignOrderModel,
                               callback: @escaping APICallback<ResponseDataListModel<Order>>) -> APIRequest {
        return request(method: .POST,
                        path: PATH_REQUEST_URL.ASSIGN_ORDER.URL,
                       input: .dto(body),
                    callback: callback);
    }
    
    
    
    
    //MARK: - ROUTE
    @discardableResult
    func getRoutes(byDate date:String? = nil, callback: @escaping APICallback<ResponseDataListModel<Route>>) -> APIRequest {
        var newDate = date;
        if newDate == nil {
            newDate = Date().toString("yyyy-MM-dd")
        }
        let params = ["date": newDate]
        return request(method: .PUT,
                       path:PATH_REQUEST_URL.GET_ROUTES_BY_DATE.URL,
                       input: .json(params),
                       callback: callback);
    }
    
    @discardableResult
    func getRoutesByCoordinator(byDate date:String = Date().toString("yyyy-MM-dd"),
                                callback: @escaping APICallback<ResponseDataModel<CoordinatorRouteModel>>) -> APIRequest {
        let path = String(format: PATH_REQUEST_URL.GET_ROUTE_BY_COORDINATOR.URL, date)
        return request(method: .GET,
                       path:path,
                       input: APIInput.empty ,
                       callback: callback);
    }
    
    
    
    @discardableResult
    func getRouteDetail(route:String, callback: @escaping APICallback<Route>) -> APIRequest {
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
    
    
    //MARK: - TRACKING
    @discardableResult
    func updateDriverLocation(long :Double, lat:Double, callback: @escaping APICallback<Route>) -> APIRequest {
        let driverID = Caches().user?.userID ?? -1
        let timestamps = __int64_t(Date().timeIntervalSince1970)
        let params = [
            KEY_LONGITUDE: long,
            KEY_LATITUDE : lat,
            KEY_TIMESTAMPS: timestamps,
            KEY_DRIVER_ID: driverID
            ] as [String : Any]
        
        return request(method: .POST,
                       path: PATH_REQUEST_URL.UPDATE_DRIVER_LOCATION.URL,
                       input: .json(params),
                       callback: callback);
    }
    
    @discardableResult
    func getDirection(fromLocation startLocation: CLLocationCoordinate2D,
                      toLocation destinationLocation: CLLocationCoordinate2D,
                      callback: @escaping APICallback<MapDirectionResponse>) -> APIRequest {
        let origin = "\(startLocation.latitude),\(startLocation.longitude)"
        let destination = "\(destinationLocation.latitude),\(destinationLocation.longitude)"
        let path = "/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(Network.googleAPIKey)"
        
        return request( method: .GET,
                        serverURL: DMSAppConfiguration.baseUrl_Google_Map,
                        path: path,
                        input: .empty,
                        callback: callback);
    }
    
    // MARK: - PROFILE
    @discardableResult
    func getUserProfile(callback: @escaping APICallback<ResponseDataModel<UserModel>>) -> APIRequest {
        return request(method: .GET,
                       path: PATH_REQUEST_URL.GET_USER_PROFILE.URL,
                       input: .empty,
                       callback: callback);
    }
  
    @discardableResult
    func updateUserProfile(_ user:UserModel, callback: @escaping APICallback<ResponseDataModel<UserModel>>) -> APIRequest {
        return request(method: .PUT,
                   path: PATH_REQUEST_URL.UPDATE_USER_PROFILE.URL,
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
