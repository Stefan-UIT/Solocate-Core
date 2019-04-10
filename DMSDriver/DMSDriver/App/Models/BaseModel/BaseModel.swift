//
//  BaseModal.swift
//
//  Created by machnguyen_uit on 6/5/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreData

class BaseModel:NSObject, Mappable  {
    
    override init() {
        //
    }

    
    //MARK: - MAPPABLE
    required init?(map: Map) {
        super.init()
    }
    
    func mapping(map: Map) {
        //
    }
    
    func getJSONString()-> [String: Any] {
        let json = self.toJSON()
        return json
    }
    
    func getJsonObject(method: ParamsMethod)-> Any {
        return self.getJSONString();
    }
    
    
    func cloneObject<T:BaseModel>() -> T? {
        let json = getJSONString()
        let obj = T(JSON: json)
        return obj
    }
}

