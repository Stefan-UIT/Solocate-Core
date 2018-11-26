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
import CoreData


public typealias ResponseDictionary = [String: Any]
public typealias ResponseArray = [Any]

public func E(_ val: String?) -> String {
  return (val != nil) ? val! : "";
}


extension BaseAPIService {
    @discardableResult
    func updateRequestFromLocalDB(_ coreRequesst:RequestModel, callback: @escaping APICallback<UserModel>) -> APIRequest {
        let method = ParamsMethod(rawValue:E(coreRequesst.method))
        var header:Dictionary<String, String>?
        
        if let data = coreRequesst.header?.data(using: .utf8) {
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,String>
                {
                    header = jsonArray
                } else {
                    print("bad json")
                }
            } catch let error as NSError {
                print(error)
            }
        }
        
        return request(method: method!,
                       serverURL: E(coreRequesst.server),
                       headers: header == nil ? nil : header!,
                       path: E(coreRequesst.path),
                       input: coreRequesst.body == nil ? APIInput.empty : APIInput.data(coreRequesst.body!),
                       callback: callback)
    }
    
    //MARK: USER
    @discardableResult
    func login(_ userLogin:UserLoginModel, callback: @escaping APICallback<ResponseDataModel<UserModel>>) -> APIRequest {
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
    func updateOrderStatus(_ order:OrderDetail,reason: Reason? = nil, callback: @escaping APICallback<OrderDetail>) -> APIRequest? {
        
        let path = String(format:PATH_REQUEST_URL.UPDATE_ORDER_STATUS.URL, "\(order.id)", order.statusCode)
        var params = ["route_id": "\(order.routeId)"]
        if let _reason = reason {
            params["reason_msg"] = _reason.message != nil ? _reason.message :  _reason.reasonDescription
            params["reason_id"] = "\(_reason.id)"
        }
        
        if !isEmpty(order.note){
            params["note"] = E(order.note)
        }
        
        if ReachabilityManager.isNetworkAvailable{
            return request(method: .PUT,
                           path: path,
                           input: .json(params),
                           callback: callback);
        }else{
            //Save request to local DB
            let data = parseJson(params)
            let request =  RequestModel.init(ParamsMethod.PUT.rawValue,
                                             E(RESTConstants.getBASEURL()),
                                             path,
                                             data)
            CoreDataManager.saveRequest(request)
            return nil
        }
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
    func submitSignature(_ file:AttachFileModel,_ orderId:String, callback: @escaping APICallback<AttachFileModel>) -> APIRequest? {
        let uri = String(format:PATH_REQUEST_URL.UPLOAD_SIGNATURE.URL, orderId)
        let headers = ["Content-Type":"multipart/form-data; boundary=\(E(file.boundary))"];
        
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
    func uploadMultipleImageToOrder(_ orderId:String,_ files:[AttachFileModel], callback: @escaping APICallback<AttachFileModel>) -> APIRequest? {
        let path = String(format:PATH_REQUEST_URL.UPLOAD_FILES.URL, orderId)
        let headers = ["Content-Type":"multipart/form-data; boundary=\(E(files.first?.boundary))"];
        
        if ReachabilityManager.isNetworkAvailable {
            return request(method: .POST,
                           headers:headers,
                           path: path,
                           input: .mutiFile(files),
                           callback: callback)
        }else {
         
            let stringHeader = jsonToString(json: headers as AnyObject)
            let data = getMutiDataFromFile(files: files)
            let request =  RequestModel.init(ParamsMethod.POST.rawValue,
                                             E(RESTConstants.getBASEURL()),
                                             path,
                                             data,
                                             stringHeader)
            CoreDataManager.saveRequest(request)
            return nil
        }
    }
    
    
    @discardableResult
    func getDriversByCoordinator(callback: @escaping APICallback<CoordinatorDriverModel>) -> APIRequest {
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
    
    
    //MARK: - TRACKING
    @discardableResult
    func updateDriverLocation(long :Double, lat:Double, callback: @escaping APICallback<Route>) -> APIRequest {
        let driverID = Caches().user?.userInfo?.id ?? -1
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
    
    @discardableResult
    func getDirection(origin: CLLocationCoordinate2D,
                      destination: CLLocationCoordinate2D,
                      waypoints:Array<CLLocationCoordinate2D>,
                      callback: @escaping APICallback<MapDirectionResponse>) -> APIRequest {
        let origin = "\(origin.latitude),\(origin.longitude)"
        let destination = "\(destination.latitude),\(destination.longitude)"
        var path = "/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(Network.googleAPIKey)"
        
        if waypoints.count > 0 {
            path += "&waypoints=optimize:true"
            for waypoint in waypoints {
                let stringWaypoint = "\(waypoint.latitude),\(waypoint.longitude)"
                path += "|" + stringWaypoint
            }
        }
        print(path)
        path = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
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
    
    
    //MARK : -TASK
    @discardableResult
    func getTaskList(_ date:String,
                     callback: @escaping APICallback<ResponseDataListModel<TaskModel>>) -> APIRequest {
        let path = String(format:PATH_REQUEST_URL.GET_LIST_TASKS.URL, date, date)
        return request(method: .GET,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getTaskDetail(_ taskId:Int,
                     callback: @escaping APICallback<TaskModel>) -> APIRequest {
        let path = String(format:PATH_REQUEST_URL.GET_TASK_DETAIL.URL, "\(taskId)")
        return request(method: .GET,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func updateTaskStatusTask(_ taskId:Int,
                           _ status:String,
                           _ reason:Reason? = nil,
                       callback: @escaping APICallback<ResponseDataModel<TaskModel>>) -> APIRequest {
        let path = String(format:PATH_REQUEST_URL.UPDATE_STATUS_TASK.URL, "\(taskId)",status)
        var params = ResponseDictionary()
        if let _reason = reason {
            params["reason_msg"] = _reason.message != nil ? _reason.message :  _reason.reasonDescription
            params["reason_id"] = "\(_reason.id)"
        }
        
        return request(method: .PUT,
                       path: path,
                       input: params.keys.count > 0 ? .json(params) : .empty,
                       callback: callback);
    }
    
  
    //MARK: -  Help Method
    func parseJson(_ rawObject: Any) -> Data? {
        guard let jsonData = (try? JSONSerialization.data(withJSONObject: rawObject, options: .init(rawValue: 0))) else {
            print("Couldn't parse [\(rawObject)] to JSON");
            return nil;
        }
        
        return jsonData
    }
    
    func getMutiDataFromFile(files:[AttachFileModel]) -> Data {
        let mutiData:NSMutableData = NSMutableData()
        
        for i in 0..<files.count {
            let file = files[i]
            let data = file.getDataObject("image_file[\(i)]")
            
            mutiData.append(data as Data);
        }
        
        return mutiData as Data;
    }
    
    func jsonToString(json: AnyObject) -> String{
        var jsonString = ""
        
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            print(convertedString ?? "defaultvalue")
            jsonString = E(convertedString)
            
        } catch let myJSONError {
            print(myJSONError)
        }
        return jsonString
    }
  

 /*
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
