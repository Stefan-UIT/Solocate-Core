//
//  ReceiveNotificationModel.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 10/25/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper

enum NotificationType:String {
    case TASK = "task"
    case ROUTE = "route"
    case ROUTE_LIST = "route_list"

}

class ReceiveNotificationModel: BaseModel {
    
    var type:String?
    var alert_id:String?
    var date_send:String?
    var body:String?
    var title:String?
    var object_data:DataObject?
    var object:String?

    
    var notiType:NotificationType {
        if let type =  NotificationType(rawValue: E(object_data?.object_type)) {
            return type
        }
        
        return NotificationType.ROUTE_LIST
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        type <- map["type"]
        alert_id <- map["alert_id"]
        date_send <- map["date_send"]
        body <- map["body"]
        title <- map["title"]
        object_data <- map["object_data"]
        
        var stringData:String = ""
        if object_data == nil { // handle object_data response a string Json
            stringData <- map["object_data"]
            let data = stringData.data(using: .utf8)!
            guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String:AnyObject] else{
                return
            }
            object_data = DataObject(JSON: json)
        }
    }
    
    struct DataObject:Mappable {
        init?(map: Map) {
            //
        }
        
        mutating func mapping(map: Map) {
            object_type  <- map["object_type"]
            object_id  <- map["object_id"]
        }
        
        var object_type:String?
        var object_id:Int?
    }
}
