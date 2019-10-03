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
    //NEW
    @IBOutlet weak var divisionLabel: UILabel!
    @IBOutlet weak var zoneLabel: UILabel!
    @IBOutlet weak var trailerTankerLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var truckLabel: UILabel!
    @IBOutlet weak var loadVolumeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
    }
    
    func loadData(_ route: Route) {
        var startDate = "NA".localized
        var endDate = "NA".localized
        var stringDate = "NA".localized
        if let start = route.start_time.date {
            startDate = HourFormater.string(from:start)
        }
        if let end = route.end_time.date {
            endDate = HourFormater.string(from:end)
            stringDate = DateFormatter.shortDate.string(from: end)
        }

        routeIDLabel.text = "#\(route.id)"
        statusLabel.text = route.status?.name?.localized
        statusLabel.textColor = route.colorStatus
        startTimeLabel.text = startDate + " - "
        endTimeLabel.text = endDate
        expectedStartDateLabel.text = stringDate.uppercased()
        durationLabel.text = CommonUtils.formatEstTime(seconds: Int64(route.totalTimeEst))
        distanceLabel.text = CommonUtils.formatEstKm(met: route.totalDistance.doubleValue)
        stopsLabel.text = (route.totalOrders > 1) ? ("\(route.totalOrders) " + "orders".localized.uppercased()) : ("\(route.totalOrders) " + "order".localized.uppercased())
        //NEW
        divisionLabel.text = Slash(route.division?.name)
        zoneLabel.text = Slash(route.zone?.name)
        companyLabel.text = Slash(route.company?.name)
        truckLabel.text = Slash(route.assignedInfo?.first?.truck?.name)
        trailerTankerLabel.text = Slash(route.trailerTankerName)
        let loadValue = Double(route.loadVolume)?.rounded(toPlaces: 1)
        loadVolumeLabel.text = "\(loadValue!)" + "%"
    }
    
}
