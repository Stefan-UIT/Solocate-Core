//
//  APIs.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import CoreLocation
import TLPhotoPicker

class APIs {
  class func login(_ email: String, password: String, completion: @escaping((_ token: String?, _ msg: String?) -> Void)) {
    let request = RESTRequest(functionName: RESTConstants.ServicesConfigs[RESTConstants.LOGIN] ?? ""
      , method: .post, encoding: .default)
    let params = ["email": email, "password": password]
    request.setParameters(params)
    request.setContentType("application/x-www-form-urlencoded")
    request.baseInvoker { (resp, error) in
      if let response = resp as? [String: Any],
      let data = response["data"] as? [String : String],
      let token = data["token"] {
        
        completion(token, nil)
      }
      else if let err = error {
        completion(nil, err.message)
      }
      else {
        guard let response = resp as? [String: Any] else {
            completion(nil, "Unknown")
            return
        }
        if let message = response["message"]  as? String {
            completion(nil, message)
        } else {
            completion(nil, "Unknown")
        }
      }
    }
  }
    
  class func forgetPassword(_ email: String, completion: @escaping((_ token: String?, _ msg: String?) -> Void)) {
        let request = RESTRequest(functionName: RESTConstants.ServicesConfigs[RESTConstants.FORGET_PASSWORD] ?? ""
            , method: .post, encoding: .default)
    
        let resetUrl = "\(RESTConstants.getBASEURL() ?? "")\(RESTConstants.ServicesConfigs[RESTConstants.RESET_PASSWORD_URL] ?? "")"
        let params = ["email": email,
                      "reset_password_url": resetUrl]
        request.setParameters(params)
        request.setContentType("application/x-www-form-urlencoded")
        request.baseInvoker { (resp, error) in
            if let response = resp as? [String: Any],
                let data = response["data"] as? [String : String],
                let forgotPassword = data["forgot_password"] {
                completion(forgotPassword, nil)
            }
            else if let err = error {
                completion(nil, err.message)
                return
            }
            else {
                guard let response = resp as? [String: Any] else {
                    completion(nil, "Unknown")
                    return
                }
                if let errors = response["errors"]  as? [String: Any] {
                    if let detail = errors["detail"] as? String {
                        completion(nil, detail)
                        return
                    }
                }
                completion(nil, "Unknown")
            }
        }
  }
  
    class func getOrderDetail(_ orderID: String, completion: @escaping ((_ resp: OrderDetail?,_ error: RESTError?, _ msg: String?) -> Void)) {
    let uri = String.init(format: RESTConstants.ServicesConfigs[RESTConstants.GET_ORDER_DETAIL] ?? "", orderID)
    let request = RESTRequest(functionName: uri, method: .get, encoding: .default)
    if let token = Caches().getTokenKeyLogin() {
      request.setAuthorization(token)
    }
    request.setContentType("application/x-www-form-urlencoded")
    request.baseInvoker { (response, error) in
      guard let resp = response as? [String: Any] else {
        completion(nil, error, error != nil ? error!.message : "error_network".localized)
        return
      }
      if let errors = resp["errors"] as? [String: Any],
        let err = Mapper<RESTResponse>().map(JSON: errors) {
        completion(nil, nil, err.message)
        return
      }
      if let orderDetail = Mapper<OrderDetail>().map(JSONObject: resp) {
        completion(orderDetail, nil, nil)
      }
    }
  }
  
  class func getRouteDetail(_ routeID: String, completion: @escaping ((_ route: Route?, _ msg: String?) -> Void)) {
    let uri = String.init(format: RESTConstants.ServicesConfigs[RESTConstants.GET_ROUTE_DETAIL] ?? "%@", routeID)
    let request = RESTRequest(functionName: uri, method: .get, encoding: .default)
    if let token = Caches().getTokenKeyLogin() as? String {
      request.setAuthorization(token)
    }
    request.baseInvoker { (response, error) in
      guard let resp = response as? [String: Any] else {
        completion(nil, error != nil ? error!.message : "error_network".localized)
        return
      }
      if let errors = resp["errors"] as? [String: Any],
        let err = Mapper<RESTResponse>().map(JSON: errors) {
        completion(nil, err.message)
        return
      }
      if let route = Mapper<Route>().map(JSONObject: resp) {
        completion(route, nil)
      }
    }
  }
  
  static func updateOrderStatus(_ orderID: String,
                                expectedStatus: String,
                                routeID: String,
                                reason: Reason? = nil,
                                _ onCompletion: OnCompletion? = nil,
                                _ onError: OnError? = nil) {
    var uri = String.init(format: RESTConstants.ServicesConfigs[RESTConstants.UPDATE_ORDER_STATUS] ?? "", orderID, expectedStatus)
    uri = uri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let request = RESTRequest(functionName: uri, method: .put, encoding: .default)
    var params = ["route_id": routeID]
    if let _reason = reason {
      params["reason_msg"] = _reason.reasonDescription
      params["reason_id"] = "\(_reason.id)"
    }
    request.setParameters(params)
    request.setContentType("application/x-www-form-urlencoded")
    if let token = Caches().getTokenKeyLogin() {
      request.setAuthorization(token)
    }
    request.baseInvoker { (resp, error) in
        if let error = error {
            onError?(error)
            return
        }
        if let jsonData = resp as? JSONData {
            if let data = jsonData["data"] as? JSONData {
                if let msg = data["msg"] as? String, msg.compare("Successful") == ComparisonResult.orderedSame {
                    onCompletion?(true, msg)
                    return
                }
            } else if let code = jsonData["code"] as? Int, let msg = jsonData["msg"] as? String {
                onError?(RESTError(code: code, msg: msg))
                return
            }
        }
        onError?(RESTError(code: 000, msg: "Sorry! Something wrong.\nPlease contact with us. Thanks."))
    }
  }
  
  static func getReasonList(_ type: String = "1", completion: @escaping ((_ reasons:[Reason]?, _ errMsg: String?) -> Void)) {
    let uri = String.init(format: RESTConstants.ServicesConfigs[RESTConstants.GET_REASON_LIST] ?? "", type)
    let request = RESTRequest(functionName: uri, method: .get, encoding: .default)
    request.baseInvoker { (resp, error) in
      if let response = resp as? [[String: Any]]{
        var list = [Reason]()
        for item in response {
          if let r = Mapper<Reason>().map(JSON: item) {
            list.append(r)
          }
        }
        completion(list, nil)
      }
      else if let err = error {
        completion(nil, err.message)
      }
    }
  }
  
  
  class func getOrders(byDate date: String? = nil, completion: @escaping ((_ route: Route?, _ msg: String?) -> Void)) {
    let request = RESTRequest(functionName: RESTConstants.ServicesConfigs[RESTConstants.GET_ORDER_BY_DATE] ?? "", method: .put, encoding: .default)
    var dateString = Date().toString("yyyy-MM-dd")
    if let _date = date {
      dateString = _date
    }
    let params = ["date": dateString]
    request.setContentType("application/x-www-form-urlencoded")
    request.setParameters(params)
    if let token = Caches().getTokenKeyLogin() {
      request.setAuthorization(token)
    }
    request.baseInvoker { (response, error) in
      guard let resp = response as? [String: Any] else {
        completion(nil, error != nil ? error!.message : "error_network".localized)
        return
      }
      if let errors = resp["errors"] as? [String: Any],
        let err = Mapper<RESTResponse>().map(JSON: errors) {
        completion(nil, err.message)
        return
      }
      if let route = Mapper<Route>().map(JSONObject: resp) {
        completion(route, nil)
      }
    }
  }
  
  static func uploadSignature(_ orderID: String, signBase64: String, completion: @escaping ((_ errMsg: String?) -> Void)) {
    let uri = String.init(format: RESTConstants.ServicesConfigs[RESTConstants.UPLOAD_SIGNATURE] ?? "%@", orderID)
    let request = RESTRequest(functionName: uri, method: .put, encoding: .default)
    request.setContentType("application/x-www-form-urlencoded")
    let params = ["sign": signBase64]
    request.setParameters(params)
    if let token = Caches().getTokenKeyLogin(){
      request.setAuthorization(token)
    }
    request.baseInvoker { (resp, error) in
        if let response = resp as? [String: Any] {
            guard let _ = response["data"] as? [String : Any] else {
                if let errors = Mapper<RESTResponse>().map(JSONObject: response["errors"]) {
                    completion(errors.message)
                }
                else {
                    if let msg = response["msg"] as? String {
                        completion("\(orderID) - \(msg)")
                    } else {
                        completion("UNKNOWN")
                    }
                }
                return
            }
            completion(nil)
        }
        if let err = error {
            completion(err.message)
        }
    }
    
  }
  
  static func updateRouteSequenceOrders(_ routeID: String, routeStatus: String, orderIDs: [String],
                                        completion: @escaping ((_ errorMsg: String?) -> Void)) {
    let params = [[
      "route_id": routeID,
      "route_sts": routeStatus,
      "order_ids": orderIDs
    ]]

    guard let baseURL = RESTConstants.getBASEURL(),
    let updateSequence = RESTConstants.ServicesConfigs[RESTConstants.UPDATE_SEQUENCE] else {
        return
    }
    APIs.invoke(params: params, uri: (baseURL+updateSequence), completion: completion)
  }
  
  static func addNewOrderItem(_ orderID: String, barcode: String, qty: String, completion: @escaping ((_ errorMsg: String?) -> Void)) {
    let params = [
      [
        "barcode": barcode,
        "qty": qty
      ]
    ]
    guard let baseURL = RESTConstants.getBASEURL(),
      let addNewItem = RESTConstants.ServicesConfigs[RESTConstants.ADD_NEW_ORDER_ITEM] else {
        return
    }
    let uri = String.init(format: baseURL+addNewItem, orderID)
    APIs.invoke(params: params, uri: uri, completion: completion)
  }
  
  static func invoke(params: Any, uri: String, completion: @escaping ((_ errorMsg: String?) -> Void)) {
    guard let url = URL(string: uri) else {
      return
    }
    let jsonData = APIs.convertArray2Json(from: params)
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData
    if let token = Caches().getTokenKeyLogin() {
      request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
    }
    Alamofire.request(request).responseJSON { (response) in
      if let errors = response.result.value as? [String: Any]  {
        if let resp = Mapper<RESTResponse>().map(JSONObject: errors["errors"]) {
          completion(resp.message)
          return
        }
      }
      completion(nil)
    }
  }
  
  static func convertArray2Json(from object:Any) -> Data? {
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
      return nil
    }
    return data
  }
  
  static func uploadFiles(_ files: [PictureObject], orderID: String, completion: @escaping ((_ errorMsg: String?) -> Void)) {
    guard let baseURL = RESTConstants.getBASEURL(),
      let uploadFiles = RESTConstants.ServicesConfigs[RESTConstants.UPLOAD_FILES] else {
        return
    }
    let url = String.init(format: "\(baseURL)\(uploadFiles)", orderID)
    var headers = [String: String]()
    if let token = Caches().getTokenKeyLogin() as? String {
      headers["Authorization"] = "Bearer " + token
    }
    
    Alamofire.upload(multipartFormData: { (formData) in
      for (idx, item) in files.enumerated() {
        let data = UIImageJPEGRepresentation(item.image, 0.4)
        let imgName = item.name.length > 0 ? item.name : "Untitle_\(idx)"
        formData.append(data ?? Data(), withName: "file[]", fileName: imgName , mimeType: "image/jpg")
      }
    }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: .post, headers: headers) { (encodingResult) in
      switch encodingResult {
      case .success(let upload, _, _):
        upload.responseJSON(completionHandler: { (response) in
          if let resp = response.result.value as? [String: Any],
            let _ = resp["data"] as? [String : Any] {
            completion(nil)
          }
        })
      case .failure(let error):
        completion(error.localizedDescription)
      }
    }
  }
  
  
  static func getDirection(fromLocation startLocation: CLLocationCoordinate2D,
                           toLocation destinationLocation: CLLocationCoordinate2D, completion: @escaping ((_ routes: [DirectionRoute]?) -> Void)) {
    let origin = "\(startLocation.latitude),\(startLocation.longitude)"
    let destination = "\(destinationLocation.latitude),\(destinationLocation.longitude)"
    
    let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(Network.googleAPIKey)"
    guard let url = URL(string: urlString) else { return }
    URLSession.shared.dataTask(with: url, completionHandler: {
      (data, response, error) in
      DispatchQueue.main.async {
        guard let _data = data else { return }
        do {
          let json = try JSONSerialization.jsonObject(with: _data, options:.allowFragments) as! [String : AnyObject]
          if let response = Mapper<MapDirectionResponse>().map(JSON: json) {
            completion(response.routes)
            return
          }
          completion(nil)
        }
        catch let err {
          completion(nil)
          print("get direction error: \(err.localizedDescription)")
        }
      }
    }).resume()
  }
  
  static func addNote(_ orderID: String, content: String, completion: @escaping ((_ note: Note?,_ msgError: String?) -> Void)) {
    let uri = String.init(format: RESTConstants.ServicesConfigs[RESTConstants.ADD_NOTE] ?? "", orderID)
    let params = ["content": content]
    let request = RESTRequest(functionName: uri, method: .post, encoding: .default)
    request.setParameters(params)
    if let token = Caches().getTokenKeyLogin() {
      request.setAuthorization("Bearer " + token)
    }
    request.baseInvoker { (resp, error) in
      if let note = Mapper<Note>().map(JSONObject: resp) {
        completion(note, nil)
      }
      else if let err = error {
        completion(nil, err.message)
      }
    }
  }
  
  static func updateOrderItemStatus(_ itemID: String, status: String, reason: Reason?, completion: @escaping ((_ msgError: String?) -> Void)) {
    let uri = String.init(format: RESTConstants.ServicesConfigs[RESTConstants.UPDATE_ORDER_ITEM_STATUS] ?? "", itemID, status)
    let request = RESTRequest(functionName: uri, method: .put, encoding: .default)
    var reasonMsg = ""
    var reasonID = ""
    if let _reason = reason {
      reasonMsg = _reason.reasonDescription
      reasonID = "\(_reason.id)"
    }
    let params = ["reason_msg": reasonMsg,"reason_id": reasonID]
    request.setParameters(params)
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
      request.setAuthorization("Bearer " + token)
    }
    request.baseInvoker { (response, error) in
      if let errors = response as? [String: Any]  {
        if let resp = Mapper<RESTResponse>().map(JSONObject: errors["errors"]) {
          completion(resp.message)
          return
        }
      }
      completion(nil)
    }
  }
  
  static func updateBarcode(_ itemID: String, newBarcode: String, completion: @escaping ((_ errorMsg: String?) -> Void)) {
    let uri = String.init(format: RESTConstants.ServicesConfigs[RESTConstants.UPDATE_BARCODE_ORDER_ITEM] ?? "", itemID)
    let request = RESTRequest(functionName: uri, method: .put, encoding: .default)
    let params = ["barcode": newBarcode]
    request.setParameters(params)
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
      request.setAuthorization("Bearer " + token)
    }
    request.baseInvoker { (resp, error) in
      if let response = resp as? [String: Any],
        let _ = response["data"] as? [String : Any] {
        completion(nil)
      }
      if let err = error {
        completion(err.message)
      }
    }
  }
  
  static func updateNotificationToken(_ token: String) {
    let request = RESTRequest(functionName: RESTConstants.ServicesConfigs[RESTConstants.UPDATE_TOKEN_FCM] ?? "", method: .post, encoding: .default)
    let params = [
      "notification_token": token,
      "device": "2" // iOS : device = 2
    ]
    request.setParameters(params)
    request.setContentType("application/x-www-form-urlencoded")
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
      request.setAuthorization("Bearer " + token)
    }
    request.baseInvoker { (resp, error) in
      print("did update token key")
    }
  }
  
    static func changePassword( _ para : [String: Any], completion: @escaping ((_ successful: Bool, _ message: String?, _ model: ChangePasswordModel?) -> Void)) {
        let request = RESTRequest(functionName: RESTConstants.ServicesConfigs[RESTConstants.CHANGE_PASSWORD] ?? ""
            , method: .post, encoding: .default)
        request.setParameters(para)
        if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
            request.setAuthorization(token)
        }
        request.setContentType("application/x-www-form-urlencoded")
        request.baseInvoker { (resp, error) in
            if let error = error {
                completion(false, error.message, nil)
                return
            }
            if let response = resp as? [String: Any] {
                if let error = response["error"] as? [String: Any] {
                    if let model = Mapper<ChangePasswordModel>().map(JSON: error) {
                        completion(false, "Change password fail", model)
                        return
                    } else {
                        completion(false, "Something wrong with data. Please check agian", nil)
                        return
                    }
                } else if let data = response["data"] as? [String: Any] {
                    if let success = data["success"] as? Bool {
                        completion(success, "Change password successful", nil)
                        return
                    }
                }
            }
            completion(false, "Something wrong with data. Please check agian", nil)
        }
  }
    
    
  static func checkToken( completion: @escaping ((_ isValid: Bool, _ message: String?) -> Void)) {
        let uri = String.init(format: RESTConstants.ServicesConfigs[RESTConstants.CHECK_TOKEN] ?? "")
        let request = RESTRequest(functionName: uri, method: .get, encoding: .default)
        if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
            request.setAuthorization(token)
        }
        request.setContentType("application/x-www-form-urlencoded")
        request.baseInvoker { (response, error) in
            
            if let error = error {
                completion(false, "\(error.message)")
                return
            }
            guard let resp = response as? [String: Any] else {
                completion(false, "Invalid token")
                return
            }
            guard let model = Mapper<CheckTokenModel>().map(JSONObject: resp) else {
                completion(false, "Invalid token")
                return
            }
            if model.status == 401 {
                completion(false, "Invalid token")
                return
            }
            completion(true, "Valid token")
        }
   }
    
    static func logout(completion: @escaping ((_ isValid: Bool, _ message: String?) -> Void)) {
        let uri = String.init(format: RESTConstants.ServicesConfigs[RESTConstants.LOGOUT] ?? "")
        let request = RESTRequest(functionName: uri, method: .get, encoding: .default)
        if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
            request.setAuthorization(token)
        }
        request.setContentType("application/x-www-form-urlencoded")
        request.baseInvoker { (response, error) in
            
            if let error = error {
                completion(false, "\(error.message)")
                return
            }
            guard let resp = response as? [String: Any] else {
                completion(false, "Logout fail")
                return
            }
            guard let data = resp["data"] as? [String: Any] else {
                completion(false, "Logout fail")
                return
            }
            guard let success = data["success"] as? Bool else {
                completion(false, "Logout fail")
                return
            }
            if success {
                completion(true, "Valid token")
            } else {
                completion(false, "Logout fail")
            }
        }
    }
    
    static func resolveAlert(_ alertID: String, _ content: String , _ onCompletion:((Bool, Any)->Void)? = nil, onError:((RESTError)->Void)? = nil) {
        let uri = String.init(format: RESTConstants.ServicesConfigs[RESTConstants.RESOLVE_ALERT] ?? "", alertID)
        let request = RESTRequest(functionName: uri, method: .put, encoding: .default)
        let params = ["comment": content]
        request.setParameters(params)

        if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
            request.setAuthorization(token)
        }
        request.setContentType("application/x-www-form-urlencoded")
        request.baseInvoker { (response, error) in
            if let err = error {
                onError?(err)
                return
            }
            if let jsonData = response as? JSONData {
                if let message = jsonData["message"] as? String {
                    onCompletion?(true, message)
                }
            }
            onError?(RESTError(code: 0, msg: "Something wrong. Please contact with us. Thanks."))
        }
    }
    
    static func getListAlertMessage(_ onCompletion:((Bool, Any?) -> Void)? = nil, _ onError:((RESTError)->Void)? = nil) {
        let uri = String.init(format: RESTConstants.ServicesConfigs[RESTConstants.GET_ALERT_DETAIL] ?? "")
        let request = RESTRequest(functionName: uri, method: .get, encoding: .default)
        if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
            request.setAuthorization(token)
        }
        request.setContentType("application/x-www-form-urlencoded")
        request.baseInvoker { (response, error) in
            if let _error = error {
                onError?(_error)
                return
            }
            if let jsonData = response as? [String: Any] {
                if let model = Mapper<ResultsRequestModel>().map(JSON: jsonData) {
                    if let status = model.status, status == true {
                        if let listAlertMessage = model.listAlertMessage {
                            onCompletion?(true, listAlertMessage)
                            return
                        } else {
                            onCompletion?(true, nil)
                            return
                        }
                    }
                }
            }
            onError?(RESTError(code: 0, msg: "Something wrong. Please contact with us. Thanks."))
        }
    }
}



