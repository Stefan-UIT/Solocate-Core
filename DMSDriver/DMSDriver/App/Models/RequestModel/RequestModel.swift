//
//  RequestModel.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 9/10/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit

class RequestModel: NSObject {
    var body: Data?
    var method: String?
    var path: String?
    var server: String?
    var header:String?
    var count: Int16 = 0
    var userId: Int64 = 0
    var timetamps:Double?
    
    override init() {
        super.init()
        timetamps = Date().timeIntervalSince1970
    }
    
    init(_ method:String,_ server:String, _ path:String,_ body:Data? = nil,_ header:String? = nil) {
        super.init()
        self.method = method
        self.server = server
        self.path = path
        self.body = body
        self.header = header
    }
}
