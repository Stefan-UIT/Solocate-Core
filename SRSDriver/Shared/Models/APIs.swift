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
  
  
}
