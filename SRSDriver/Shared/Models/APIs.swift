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
    let request = RESTRequest(functionName: RESTConstants.login, method: .post, encoding: .default)
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
        completion(nil, "Unknown")
      }
    }
  }
  
  class func getOrderDetail(_ orderID: String, completion: @escaping ((_ resp: OrderDetail?, _ msg: String?) -> Void)) {
    let uri = String.init(format: RESTConstants.orderDetails, orderID)
    let request = RESTRequest(functionName: uri, method: .get, encoding: .default)
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
      request.setAuthorization(token)
    }
    request.setContentType("application/x-www-form-urlencoded")
    request.baseInvoker { (resp, error) in
      if let orderDetail = Mapper<OrderDetail>().map(JSONObject: resp) {
        completion(orderDetail, nil)
      }
      else if let err = error {
        completion(nil, err.message)
      }
      else {
        completion(nil, "Unknown")
      }
    }
  }
  
  static func updateOrderStatus(_ orderID: String, expectedStatus: String, routeID: String, reason: Reason? = nil, completion: @escaping((_ errMsg: String?) -> Void)) {
    var uri = String.init(format: RESTConstants.updateOrderStatus, orderID, expectedStatus)
    uri = uri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let request = RESTRequest(functionName: uri, method: .put, encoding: .default)
    var params = ["route_id": routeID]
    if let _reason = reason {
      params["reason_msg"] = _reason.reasonDescription
      params["reason_id"] = "\(_reason.id)"
    }
    request.setParameters(params)
    request.setContentType("application/x-www-form-urlencoded")
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
      request.setAuthorization(token)
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
  
  static func getReasonList(_ type: String = "1", completion: @escaping ((_ reasons:[Reason]?, _ errMsg: String?) -> Void)) {
    let uri = String.init(format: RESTConstants.getListReason, type)
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
    let request = RESTRequest(functionName: RESTConstants.getOrdersByDate, method: .put, encoding: .default)
    var dateString = Date().toString("yyyy-MM-dd")
    if let _date = date {
      dateString = _date
    }
    let params = ["date": dateString]
    request.setContentType("application/x-www-form-urlencoded")
    request.setParameters(params)
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
      request.setAuthorization(token)
    }
    request.baseInvoker { (resp, error) in
      if let route = Mapper<Route>().map(JSONObject: resp) {
        completion(route, nil)
      }
      else if let err = error {
        completion(nil, err.message)
      }
      else {
        completion(nil, "Unknown")
      }
    }
  }
  
  static func uploadSignature(_ orderID: String, signBase64: String, completion: @escaping ((_ errMsg: String?) -> Void)) {
    let uri = String.init(format: RESTConstants.uploadSignature, orderID)
    let request = RESTRequest(functionName: uri, method: .put, encoding: .default)
    request.setContentType("application/x-www-form-urlencoded")
    let params = ["sign": signBase64]
    request.setParameters(params)
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
      request.setAuthorization(token)
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
  
  static func updateRouteSequenceOrders(_ routeID: String, routeStatus: String, orderIDs: [String],
                                        completion: @escaping ((_ errorMsg: String?) -> Void)) {
    let params = [[
      "route_id": routeID,
      "route_sts": routeStatus,
      "order_ids": orderIDs
    ]]

    let jsonData = APIs.convertArray2Json(from: params)
    guard let url = URL(string: RESTConstants.baseURL + RESTConstants.updateSequence) else {
      return
    }
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
      request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
    }
    Alamofire.request(request).responseJSON { (response) in
      print(response)
    }
  }
  
  static func convertArray2Json(from object:Any) -> Data? {
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
      return nil
    }
    return data
  }
  
  static func uploadFiles(_ files: [TLPHAsset], name: String = "", orderID: String, completion: @escaping ((_ errorMsg: String?) -> Void)) {
    let url = String.init(format: "\(RESTConstants.baseURL)\(RESTConstants.uploadFiles)", orderID)
    var headers = [String: String]()
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
      headers["Authorization"] = "Bearer " + token
    }
//    headers["Content-Type"] = "multipart/form-data"
    
    Alamofire.upload(multipartFormData: { (formData) in
      for item in files {
        let data = UIImageJPEGRepresentation(item.fullResolutionImage!, 0.4)
        let imgName = name.length > 0 ? name : item.originalFileName ?? "image"
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
                           toLocation destinationLocation: CLLocationCoordinate2D, completion: @escaping ((_ polyLines: [String]?) -> Void)) {
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
          guard let routes = json["routes"] as? [[String: Any]] else { return }
          var lines: [String] = [String]()
          for route in routes {
            if let overview = route["overview_polyline"] as? [String: Any],
              let points = overview["points"] as? String {
              lines.append(points)
              completion(lines)
            }
          }
        }
        catch let err {
          print("get direction error: \(err.localizedDescription)")
        }
      }
    }).resume()
  }
  
  static func addNote(_ orderID: String, content: String, completion: @escaping ((_ note: Note?,_ msgError: String?) -> Void)) {
    let uri = String.init(format: RESTConstants.addNote, orderID)
    let params = ["content": content]
    let request = RESTRequest(functionName: uri, method: .post, encoding: .default)
    request.setParameters(params)
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
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
  
  static func updateOrderItemStatus(_ itemID: String, status: String, reason: Reason?, completion: @escaping (() -> Void)) {
    let uri = String.init(format: RESTConstants.updateItemStatus, itemID, status)
    let request = RESTRequest(functionName: uri, method: .put, encoding: .default)
    var reasonMsg = ""
    var reasonID = ""
    if let _reason = reason {
      reasonMsg = _reason.reasonDescription
      reasonID = "\(_reason.id)"
    }
    let params = ["reason_msg": reasonMsg,"reason_id ": reasonID]
    request.setParameters(params)
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
      request.setAuthorization("Bearer " + token)
    }
    request.baseInvoker { (resp, error) in
      print(resp)
    }
  }
  
  
}
