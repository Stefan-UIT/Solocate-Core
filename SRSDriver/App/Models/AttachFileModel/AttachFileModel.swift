//
//  AttachFileModel.swift
//  Sel2B
//
//  Created by machnguyen_uit on 6/6/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class AttachFileModel: BaseModel {
  
  var mimeType:String? = "application/octet-stream"
  let boundary:String = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
  
  var name:String?
  var id:String?
  var contentFile:Data?
  var type:String?
  var link:String?
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  override func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
    link <- map["link"]
  }
  
  
  override func getJsonObject(method: ParamsMethod) -> Any {
    let dic:ResponseDictionary = [:]
    if (method == .POST) { // upload file
      
      //let contentType = "multipart/form-data; boundary=" + boundary
      
      let fileParamConstant = "image_file"
      let boundaryStart = "--\(boundary)\r\n"
      let boundaryEnd = "--\(boundary)--\r\n"
      let contentDispositionString = "Content-Disposition: form-data; name=\"\(fileParamConstant)\"; filename=\"\(E(name))\"\r\n"

      let contentTypeString = "Content-Type: \(E(mimeType))\r\n\r\n"
      
      let requestBodyData : NSMutableData = NSMutableData()
      
      //value
      requestBodyData.append(boundaryStart.data(using: String.Encoding.utf8)!)
      requestBodyData.append(contentDispositionString.data(using: String.Encoding.utf8)!)
      requestBodyData.append(contentTypeString.data(using: String.Encoding.utf8)!)
      requestBodyData.append(contentFile!)
      requestBodyData.append("\r\n".data(using: String.Encoding.utf8)!)
      requestBodyData.append(boundaryEnd.data(using:  String.Encoding.utf8)!)
      
      return requestBodyData;

    }else {
      //
    }
    
    return dic
  }
    
    func getDataObject(_ fileParam:String) -> NSMutableData {
        //let contentType = "multipart/form-data; boundary=" + boundary
        
        let fileParamConstant = fileParam
        let boundaryStart = "--\(boundary)\r\n"
        let boundaryEnd = "--\(boundary)--\r\n"
        let contentDispositionString = "Content-Disposition: form-data; name=\"\(fileParamConstant)\"; filename=\"\(E(name))\"\r\n"
        
        let contentTypeString = "Content-Type: \(E(mimeType))\r\n\r\n"
        
        let requestBodyData : NSMutableData = NSMutableData()
        
        //value
        requestBodyData.append(boundaryStart.data(using: String.Encoding.utf8)!)
        requestBodyData.append(contentDispositionString.data(using: String.Encoding.utf8)!)
        requestBodyData.append(contentTypeString.data(using: String.Encoding.utf8)!)
        requestBodyData.append(contentFile!)
        requestBodyData.append("\r\n".data(using: String.Encoding.utf8)!)
        requestBodyData.append(boundaryEnd.data(using:  String.Encoding.utf8)!)
        
        return requestBodyData;
  }
}
