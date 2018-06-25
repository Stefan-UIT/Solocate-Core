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
  
  var name:String?
  var id:String?
  var contentFile:Data?
  var type:String?
  var mimeType:String? = "application/octet-stream"
  let boundary:String = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
  
  required public convenience init?(map: Map) {
    self.init()
  }
  
  override public func mapping(map: Map) {
    name <- map["name"]
    id <- map["id"]
    super.mapping(map: map)
  }
  
  
  override func getJsonObject(method: ParamsMethod) -> Any {
    let dic:ResponseDictionary = [:]
    if (method == .POST) { // upload file
      
      //let contentType = "multipart/form-data; boundary=" + boundary
      
      let fileParamConstant = "file[]"
      let boundaryStart = "--\(boundary)\r\n"
      let boundaryEnd = "--\(boundary)--\r\n"
      let contentDispositionString = "Content-Disposition: form-data; name=\"\(fileParamConstant)\"; filename=\"\(E(name))\"\r\n"
//      let contentKeyString = "Content-Disposition: form-data; name=\"file[]\"\r\n\r\n"
      let contentTypeString = "Content-Type: \(E(mimeType))\r\n\r\n"
      
      let requestBodyData : NSMutableData = NSMutableData()
      
      //key
      /*
       requestBodyData.append(boundaryStart.data(using: String.Encoding.utf8)!)
       requestBodyData.append(contentKeyString.data(using: String.Encoding.utf8)!)
       requestBodyData.append("file[]\r\n".data(using: String.Encoding.utf8)!)
       */
      
      //value
      requestBodyData.append(boundaryStart.data(using: String.Encoding.utf8)!)
      requestBodyData.append(contentDispositionString.data(using: String.Encoding.utf8)!)
      requestBodyData.append(contentTypeString.data(using: String.Encoding.utf8)!)
      requestBodyData.append(contentFile!)
      requestBodyData.append("\r\n".data(using: String.Encoding.utf8)!)
      requestBodyData.append(boundaryEnd.data(using:  String.Encoding.utf8)!)
      
      return requestBodyData;
      /*
       #define FormFile(FileName, MineType, FileContent) \
       [data appendData:[[NSString stringWithFormat:@"--%@\r\n", __boundary] dataUsingEncoding:NSUTF8StringEncoding]]; \
       [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file", _##FileName] dataUsingEncoding:NSUTF8StringEncoding]]; \
       [data appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", MineType] dataUsingEncoding:NSUTF8StringEncoding]]; \
       [data appendData:_##FileContent]; \
       [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
       
       
       #define FormKV(Obj) FormKVKey(Obj, @#Obj, __boundary)
       #define FormKVKey(Value, Key, Boundary) \
       [data appendData:[[NSString stringWithFormat:@"--%@\r\n", Boundary] dataUsingEncoding:NSUTF8StringEncoding]]; \
       [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", Key] dataUsingEncoding:NSUTF8StringEncoding]]; \
       [data appendData:[[MNSString stringWithFormat:@"%@\r\n", _##Value] dataUsingEncoding:NSUTF8StringEncoding]];
       */
      
    }else {
      
    }
    
    return dic;
  }
  
}
