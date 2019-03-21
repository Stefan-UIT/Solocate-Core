//
//  WarehouseModel.swift
//  SRSDriver
//
//  Created by Trung Vo on 7/5/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import Foundation
import ObjectMapper
import GoogleMaps

class WarehouseModel: BaseModel {
    // MARK: - Variables
    var id = -1
    var name: String?
    var latLong : String?
    var latitude:Double = 0.0
    var longitude: Double = 0.0

    override init() {
        super.init()
    }
    
    // MARK: - Methods
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map[KEY_ID]
        name <- map[KEY_NAME]
        latLong <- map[KEY_LAT_LONG]
        
        if latLong != nil {
            let array = latLong!.components(separatedBy: ",")
            latitude    = array[0].doubleValue
            longitude   = array[1].doubleValue
        }
    }
}

// MARK: - Map & Location
extension WarehouseModel {
    func toGMSMarker() -> GMSMarker {
        let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return GMSMarker(position: position)
    }
}
