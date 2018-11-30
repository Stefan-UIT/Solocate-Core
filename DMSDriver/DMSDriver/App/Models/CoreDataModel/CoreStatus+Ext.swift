//
//  CoreStatus.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 11/30/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation

extension CoreStatus{
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

