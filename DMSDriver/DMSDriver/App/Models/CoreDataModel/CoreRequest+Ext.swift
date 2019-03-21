//
//  CoreRequest+Ext.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 9/10/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation
import CoreData

extension CoreRequest{
    
    func setAttributeFrom(_ requestModel:RequestModel)  {
        
    }
    
    func convertToRequestModel() -> RequestModel {
        let requestModel = RequestModel()
        requestModel.body = body
        requestModel.header = header
        requestModel.method = method
        requestModel.server = server
        requestModel.path = path
        requestModel.timetamps = timetamps
        
        return requestModel
    }
}
