//
//  CoreLocation+Ext.swift
//  Gadot Dev
//
//  Created by Phong Nguyen on 10/31/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

extension CoreLocation{
    func setAttributeFrom(_ location: Address? = nil)  {
        id = Int16(location?.id ?? 0)
        locName = location?.loc_name
        address = location?.address
        apartment = location?.apartment
        cttName = location?.ctt_name
        cttPhone = location?.ctt_phone
        endTime = location?.end_time
        startTime = location?.start_time
        floor = location?.floor
        number = location?.number
        lattd = location?.lattd
        lngtd = location?.lngtd
        name = location?.name
        phone = location?.phone
        seq = Int16(location?.seq ?? 0)
        srvcTime = Int64(location?.srvc_time ?? 0)
        
    }
    
    func convertTocLocationModel() -> Address {
        let location = Address()
        location.id = Int(id)
        location.loc_name = locName
        location.address = address
        location.apartment = apartment
        location.ctt_name = cttName
        location.ctt_phone = cttPhone
        location.end_time = endTime
        location.start_time = startTime
        location.floor = floor
        location.number = number
        location.lattd = lattd
        location.lngtd = lngtd
        location.name = name
        location.phone = phone
        location.seq = Int(seq)
        location.srvc_time = Int(srvcTime)
        return location
    }
}
