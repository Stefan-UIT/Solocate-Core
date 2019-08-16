//
//  CoreRouteStatus+Ext.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 8/16/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

extension CoreRouteStatus{
    func setAttributeFrom(_ status: Status? = nil)  {
        guard let _status = status else {
            return
        }
        id = Int16(_status.id ?? 0)
        name = _status.name
        code = _status.code
    }
    
    func convertToStatusModel() -> Status {
        let status = Status()
        status.id = Int(id)
        status.code = code
        status.name = E(name)
        return status
    }
}
