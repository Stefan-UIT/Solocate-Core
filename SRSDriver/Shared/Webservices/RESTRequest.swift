//
//  RESTRequest.swift
//  CoreWebservice
//
//  Created by phunguyen on 3/7/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

typealias RESTAPICompletion = (_ result: Any?, _ error: RESTError?) -> Void

class RESTRequest: NSObject {
  var baseURL: String = ""
  var params: [String: Any] = [:]
  var headers: [String: String] = RESTConstants.headers
  var multiparts = NSMutableArray()
  var requestMethod: HTTPMethod = .get
  var endcoding: URLEncoding = .default
  
  func baseInvoker(_ completion: @escaping RESTAPICompletion) {
    print("baseURL - \(self.baseURL)")
    Alamofire.request(self.baseURL, method: self.requestMethod, parameters: self.params, encoding: self.endcoding, headers: self.headers)
      .responseJSON { (response) in
        self.handleResponse(response, completion: completion)
    }
  }
  
  private func handleResponse(_ response: DataResponse<Any>, completion: RESTAPICompletion) {
    switch response.result {
    case .success(let success):
        if let success = success as? [String: Any] {
            if let errors = success["errors"] as? [String: Any] {
                if let statusCode = errors["status_code"] as? Int {
                    if statusCode == 401 {
                        completion(nil, RESTError(code: statusCode, msg: "Your Account Permission Denied"))
                        return
                    }
                }
            }
        }
      completion(success, nil)
    case .failure( _):
      completion(nil, RESTError.parseError(response))
    }
  }
  
  func addQueryParam(_ name: String, value: Any) {
    if let dataValue = value as? NSData {
      params[name] = dataValue
    }
    else {
      params[name] = value as? String
    }
  }
  
  func setContentType(_ type: String) {
    headers[RESTConstants.requestContentTypeKey] = type
  }
  
  func setAccept(_ accept: String) {
    headers[RESTConstants.requestAcceptKey] = accept
  }
  
  func setAuthorization(_ token: String) {
    print("DMS - Token : \(token)")
    headers[RESTConstants.requestAuthorizationKey] = "Bearer " + token
  }
  
  func addHeader(_ name: String, value: String) {
    headers[name] = value
  }
  
  
  func setParameters(_ param: [String: Any]) {
    self.params = param
  }
      
  
  private func handleInitialization(url: String, method: HTTPMethod, encoding: URLEncoding) {
    self.baseURL = url
    self.endcoding = encoding
    self.requestMethod = method
  }
  
  
  init(baseURL: String, functionName: String, method: HTTPMethod, encoding: URLEncoding) {
    super.init()
    self.handleInitialization(url: baseURL + functionName, method: method, encoding: encoding)
  }
  
  init(functionName: String, method: HTTPMethod, encoding: URLEncoding) {
    super.init()
    let baseURL = RESTConstants.getBASEURL() ?? ""
    self.handleInitialization(url: baseURL + functionName, method: method, encoding: encoding)
  }
}
