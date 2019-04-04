//
//  Double+Ext.swift
//  DMSDriver
//
//  Created by Mach Van  Nguyen on 3/29/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
