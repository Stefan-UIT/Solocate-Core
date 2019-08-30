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

public func Slash(_ val: String?) -> String {
    return (val != nil && !val!.isEmpty) ? val! : "-";
}

public func IntSlash(_ val: Int?) -> String {
    return (val != nil) ? "\(val!)" : "-";
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
    
    //GET_LIST_STATUS
    @discardableResult
    func getListRouteStatus(callback: @escaping APICallback<ResponseDataModel<ResponseArrData<Status>>>) -> APIRequest {
        return request(method: .GET,
                       path: PATH_REQUEST_URL.GET_LIST_ROUTE_STATUS.URL,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getListStatus(callback: @escaping APICallback<ResponseDataModel<ResponseArrData<Status>>>) -> APIRequest {
        return request(method: .GET,
                       path: PATH_REQUEST_URL.GET_LIST_STATUS.URL,
                       input: .empty,
                       callback: callback);
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
    func updateDriverLocation(long :Double, lat:Double,routeIds:[Int], callback: @escaping APICallback<Route>) -> APIRequest {
        let driverID = Caches().user?.userInfo?.id ?? -1
        let driverName = Caches().user?.userInfo?.userName ?? ""
        Caches().lastLocationSubmited = CLLocationCoordinate2D(latitude: lat, longitude: long)

        let timestamps = __int64_t(Date().timeIntervalSince1970)
        let params = [
            KEY_LONGITUDE: long,
            KEY_LATITUDE : lat,
            KEY_TIMESTAMPS: timestamps,
            KEY_DRIVER_ID: driverID,
            KEY_DRIVER_NAME:driverName,
            KEY_ROUTES:routeIds
            ] as [String : Any]
        
        return request(method: .POST,
                       serverURL:
            RESTConstants.SERVER_TRACKING_URL(),
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
        
    
    //MARK : -TASK
    @discardableResult
    func getTaskList(_ timeData:TimeDataItem,
                     callback: @escaping APICallback<ResponseDataModel<ResponseDataListModel<TaskModel>>>) -> APIRequest {
        let startDate = DateFormatter.filterDate.string(from: timeData.startDate ?? Date())
        let endDate = DateFormatter.filterDate.string(from: timeData.endDate ?? Date())
        let path = String(format:PATH_REQUEST_URL.GET_LIST_TASKS.URL, startDate, endDate)
        return request(method: .GET,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getTaskDetail(_ taskId:Int,
                     callback: @escaping APICallback<ResponseDataModel<TaskModel>>) -> APIRequest {
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
    
    
    //MARK : - Returned Items
    @discardableResult
    func getReturnedItems(_ timeData:TimeDataItem,page:Int = 1,
                     callback: @escaping APICallback<ResponseDataModel<ResponseDataListModel<ReturnedItem>>>) -> APIRequest {
        let startDate = DateFormatter.filterDate.string(from: timeData.startDate ?? Date())
        let endDate = DateFormatter.filterDate.string(from: timeData.endDate ?? Date())
        var path = String(format:PATH_REQUEST_URL.GET_RETURNED_ITEMS.URL, startDate, endDate)
        
//        var path = String(format:PATH_REQUEST_URL.GET_RETURNED_ITEMS_TEMP.URL)
        path = path + "&page=\(page)&limit=10"
        return request(method: .GET,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
    

    func updateReturnedItem(_ itemID:Int,
                            returnedQty:Int?,
                            signedFile:AttachFileModel?,
                            signName:String?,
                            note:String?,
                               callback: @escaping APICallback<ResponseDataModel<ReturnedItem>>){
        let path = String(format:PATH_REQUEST_URL.RETURNED_ITEM_DETAIL.URL, "\(itemID)")
        
        var params = ResponseDictionary()
        if let value = returnedQty {
            params["dlvd_qty"] = value
        }
        if let value = signName {
            params["sig_name"] = value
        }
        if let value = note {
            params["note"] = value
        }
        if let file = signedFile {
            let url = E(SDBuildConf.serverUrlString()).appending(path)
            requestWithFormDataType(url: url,
                                    method: .post,
                                    files: [file],
                                    parameters: params,
                                    callback: callback)
            return
        }
        
        let _ = request(method: .POST,
                       path: path,
                       input: .json(params),
                       callback: callback);
    }
    
    func submitSignatures(_ file:AttachFileModel,_ order:Order, _ name:String, callback: @escaping APICallback<Order>) {
        let path = String(format:PATH_REQUEST_URL.UPDATE_ORDER_STATUS.URL, "\(order.id)","\(order.status?.id ?? 0)")
        let url = E(SDBuildConf.serverUrlString()).appending(path)
        
        //let headers = ["Content-Type":"multipart/form-data; boundary=\(E(file.boundary))"];
        let params = [
            "route_id": "\(order.route_id)",
            "sig_name":name
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
    func getReturnedItemDetail(_ itemID:Int,
                       callback: @escaping APICallback<ResponseDataModel<ReturnedItem>>) -> APIRequest {
        let path = String(format:PATH_REQUEST_URL.RETURNED_ITEM_DETAIL.URL, "\(itemID)")
        return request(method: .GET,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func rejectReturnedItem(_ itemID:Int,
                          callback: @escaping APICallback<ResponseDataModel<EmptyModel>>) -> APIRequest {
        let path = String(format:PATH_REQUEST_URL.REJECT_RETURNED_ITEM.URL, "\(itemID)")
        return request(method: .POST,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func cancelReturnedItem(_ itemID:Int,
                            callback: @escaping APICallback<ResponseDataModel<EmptyModel>>) -> APIRequest {
        let path = String(format:PATH_REQUEST_URL.CANCEL_RETURNED_ITEM.URL, "\(itemID)")
        return request(method: .POST,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func finishReturnedItem(_ itemID:Int,
                            callback: @escaping APICallback<ResponseDataModel<EmptyModel>>) -> APIRequest {
        let path = String(format:PATH_REQUEST_URL.FINISH_RETURNED_ITEM.URL, "\(itemID)")
        return request(method: .POST,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getLanguagesList(
        callback: @escaping APICallback<ResponseDataListModel<LanguageModel>>) -> APIRequest {
        let path = String(format:PATH_REQUEST_URL.GET_LIST_LANGUAGE.URL, "ios", "DMS")
        return request(method: .GET,
                       path: path,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func updateCODValue(_ value:Double,
                        orderID:Int,
                              callback: @escaping APICallback<ResponseDataModel<Order>>) -> APIRequest {
        let path = String(format:PATH_REQUEST_URL.UPDATE_ORDER.URL, "\(orderID)")
        var params = ResponseDictionary()
        params["cod_rcvd"] = value
        
        return request(method: .PUT,
                       path: path,
                       input: .json(params),
                       callback: callback);
    }
    
    @discardableResult
    func getDriverList(byRoute route:Route,
                               callback: @escaping APICallback<ResponseDataListModel<Driver>>) -> APIRequest {
        let startTime = route.start_time
        let endTime = route.end_time
        var path:String!
        if let companyID = route.company?.id {
            path = String(format: PATH_REQUEST_URL.GET_DRIVER_LIST.URL, startTime,endTime, "\(companyID)")
        } else {
            path = String(format: PATH_REQUEST_URL.GET_DRIVER_LIST.URL, startTime,endTime)
        }
        
        
        let encodedUrl = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return request(method: .GET,
                       path: encodedUrl!,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func getTruckList(byRoute route:Route,
                       callback: @escaping APICallback<ResponseDataListModel<Truck>>) -> APIRequest {
        let startTime = route.start_time
        let endTime = route.end_time
        var path:String!
        if let companyID = route.company?.id {
            path = String(format: PATH_REQUEST_URL.GET_TRUCK_LIST.URL, startTime,endTime, "\(companyID)")
        } else {
            path = String(format: PATH_REQUEST_URL.GET_TRUCK_LIST.URL, startTime,endTime)
        }
        
        let encodedUrl = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return request(method: .GET,
                       path: encodedUrl!,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func assignDriver(_ driverID:Int,
                      toRoute routeID:Int,
                       callback: @escaping APICallback<ResponseDataModel<EmptyModel>>) -> APIRequest {
        let param = ["driver_id": driverID]
        let path = String(format: PATH_REQUEST_URL.ASSIGN_TRUCK_DRIVER.URL, "\(routeID)")
        return request(method: .PUT,
                       path: path,
                       input: .json(param),
                       callback: callback);
    }
    
    @discardableResult
    func assignTruck(_ truckID:Int,
                      toRoute routeID:Int,
                      callback: @escaping APICallback<ResponseDataModel<EmptyModel>>) -> APIRequest {
        let param = ["truck_id": truckID]
        let path = String(format: PATH_REQUEST_URL.ASSIGN_TRUCK_DRIVER.URL, "\(routeID)")
        return request(method: .PUT,
                       path: path,
                       input: .json(param),
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
