//
//  Date.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import Foundation

extension Date {
  func toString(_ format: String? = nil) -> String {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "dd/MM/yyyy"
    if let _format = format {
      dateFormat.dateFormat = _format
    }
    return dateFormat.string(from: self)
  }
  
  
}
