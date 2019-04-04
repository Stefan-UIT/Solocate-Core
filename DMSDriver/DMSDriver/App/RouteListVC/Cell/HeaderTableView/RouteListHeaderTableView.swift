//
//  RouteListHeaderTableView.swift
//  SRSDriver
//
//  Created by MrJ on 1/21/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit

class RouteListHeaderTableView: BaseView {

    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func loadData(_ route: Route) {
        driverNameLabel.text = route.driver_name
        dateLabel.text = Date().toString(route.date, "mm/dd/yyyy", "MMM dd")
    }
}
