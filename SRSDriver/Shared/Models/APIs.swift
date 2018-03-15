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
  
  
}
