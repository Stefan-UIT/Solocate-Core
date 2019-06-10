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
        let stringDate = DateFormatter.shortDate.string(from: route.end_time.date ?? Date())
        let startDate = HourFormater.string(from: route.start_time.date ?? Date())
        let endDate = HourFormater.string(from: route.end_time.date ?? Date())

        routeIDLabel.text = "#\(route.id)"
        statusLabel.text = route.status?.name
        statusLabel.textColor = route.colorStatus
        startTimeLabel.text = startDate + " - "
        endTimeLabel.text = endDate
        expectedStartDateLabel.text = stringDate.uppercased()
        durationLabel.text = CommonUtils.formatEstTime(seconds: Int64(route.totalTimeEst))
        distanceLabel.text = CommonUtils.formatEstKm(met: route.totalDistance.doubleValue)
        stopsLabel.text = (route.totalOrders > 1) ? "\(route.totalOrders) Orders".localized.uppercased() : "\(route.totalOrders) Order".localized.uppercased()
    }
}
