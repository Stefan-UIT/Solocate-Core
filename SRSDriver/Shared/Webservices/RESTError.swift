//
//  RESTError.swift
//  CoreWebservice
//
//  Created by phunguyen on 3/7/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

class RESTError: RESTResponse {
  
  convenience init(code: Int, msg: String) {
    self.init()
    statusCode = code
    message = msg
  }
  
  static func parseError(_ response: DataResponse<Any>) -> RESTError {
    if let errorServer = Mapper<RESTError>().map(JSONObject: response.result.value) {
      return errorServer
    }
    else if let error = response.error {
      let _err = RESTError()
      _err.message = error.localizedDescription
      _err.statusCode = 1001
      return _err
    }
    else if let error = response.result.error {
      let _err = RESTError()
      _err.message = error.localizedDescription
      _err.statusCode = 1002
      return _err
    }
    else {
      let _err = RESTError()
      _err.message = "Unknown"
      _err.statusCode = 10000000
      return _err
    }
  }

}
