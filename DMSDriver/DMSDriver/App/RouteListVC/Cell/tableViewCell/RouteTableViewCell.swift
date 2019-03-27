//
//  RouteTableViewCell.swift
//  SRSDriver
//
//  Created by MrJ on 1/21/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {

    @IBOutlet weak var routeIDLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var expectedStartDateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stopsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
    }
    
    func loadData(_ route: Route) {
        let stringDate:String = Date().toString(route.date, "mm/dd/yyyy", "MMM dd")
        routeIDLabel.text = "#\(route.id)"
        statusLabel.text = route.route_name_sts
        startTimeLabel.text = route.startDate + " - "
        endTimeLabel.text = route.endDate
        expectedStartDateLabel.text = stringDate.uppercased()
        durationLabel.text = "\(route.totalTimeEst) Hours".localized.uppercased()
        distanceLabel.text = "\(route.totalDistance) KM"
        stopsLabel.text = "\(route.totalStops) Stops".localized
    }
}
