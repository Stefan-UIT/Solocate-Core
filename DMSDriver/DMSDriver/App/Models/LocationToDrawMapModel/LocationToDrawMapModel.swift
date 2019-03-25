//
//  LocationToDrawMapModel.swift
//  SRSDriver
//
//  Created by MrJ on 2/22/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit

class LocationToDrawMapModel: NSObject {
    var seq: Int?
    var latitude: Double?
    var longitude: Double?
    
    init(_ seq: Int? = nil, _ latitude: Double? = nil, _ longitude: Double? = nil) {
        super.init()
        self.seq = seq
        self.latitude = latitude
        self.longitude = longitude
    }
}
