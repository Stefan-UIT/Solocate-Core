//
//  MessageAPI.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 4/3/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import Foundation
import ObjectMapper

class MessageAPI {
  static func updateMessageStatus(_ messageID: String) {
    
  }
  
  static func addNewMessage(_ routeID: String, content: String, completion: @escaping ((_ message: Message?,_ errMsg: String?) -> Void)) {
    let request = RESTRequest(functionName: RESTConstants.configs[RESTConstants.CREATE_NEW_MESSAGE] ?? "", method: .post, encoding: .default)
    let params = [
      "route_id": routeID,
      "content": content
    ]
    request.setParameters(params)
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
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
      if let data = resp["data"] as? [String: Any],
        let message = Mapper<Message>().map(JSON: data) {
        completion(message,nil)
      }
    }
  }
  
  static func getList(_ routeID: String, completion:@escaping ((_ messages: [Message]?, _ errMsg: String?) -> Void)) {
    let uri = String.init(format: RESTConstants.configs[RESTConstants.GET_LIST_NOTIFICATIONS] ?? "%@", routeID)
    let request = RESTRequest(functionName: uri, method: .get, encoding: .default)
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
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
      if let data = resp["data"] as? [String: Any],
        let messageResp = Mapper<ListMessageResponse>().map(JSON: data) {
        completion(messageResp.messages, nil)
      }
    }
  }
  
  static func readMessage(_ messageID: String) {
    let uri = String.init(format: RESTConstants.configs[RESTConstants.READ_MESSAGE] ?? "", messageID)
    let request = RESTRequest(functionName: uri, method: .put, encoding: .default)
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
      request.setAuthorization(token)
    }
    request.baseInvoker { (resp, error) in
      print("did update status for message: \(messageID)")      
    }
  }
  
  static func getMessageNumber(_ type: String, routeID: String, completion: @escaping ((_ number: Int?,_ errMSg: String?) -> Void)) {
    let uri = String.init(format: RESTConstants.configs[RESTConstants.GET_COUNT_MESSAGE_NUMBER] ?? "%@%@", type, routeID)
    let request = RESTRequest(functionName: uri, method: .get, encoding: .default)
    if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String {
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
      if let message = Mapper<MessageCountResponse>().map(JSON: resp) {
        completion(message.count,nil)
      }
    }
  }
  
  class MessageCountResponse: NSObject, Mappable {
    required convenience init?(map: Map) {
      self.init()
    }
    var count: Int = -1
    func mapping(map: Map) {
      count <- map["data.total_row"]
    }
  }
  
  class ListMessageResponse: NSObject, Mappable {
    var messages: [Message]!
    var total: Int = 0
    required convenience init?(map: Map) {
      self.init()
    }
    
    func mapping(map: Map) {
      total <- map["total"]
      messages <- map["data"]
    }
    
    
  }
  
  

  
  
}


