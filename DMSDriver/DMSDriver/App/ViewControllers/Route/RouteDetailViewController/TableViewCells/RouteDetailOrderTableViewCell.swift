//
//  RouteDetailOrderTableViewCell.swift
//  SRSDriver
//
//  Created by MrJ on 1/22/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit

class RouteDetailOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var mContentView: UIView!
    @IBOutlet weak var dotView: UIView!
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var statusButton: UIButton!
    
    // MARK: Variables
    private var normalColorTitleText = UIColor(hex: "#959DAD")
    private var normalColorText = UIColor(hex: "#454F63")
    private var normalColorDateText = UIColor(hex: "#78849E", alpha: 0.57)
    private var normalColorView = UIColor(hex: "#FFFFFF")
    
    private var finishColorText = UIColor(hex: "#1032A4")
    private var finishColorDateText = UIColor(hex: "#1032A4", alpha: 0.57)
    private var finishColorView = UIColor(hex: "#EFF3FF")
    
    // Color Status Button
    private var newColorStatusButton = UIColor(hex: "#4CD493")
    private var finishColorStatusButton = UIColor(hex: "#5773FF")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
    }
    
    /*
    func loadData(_ location: LocationModel,_ isFullData: Bool? = true, _ isStarted: Bool? = false) {
        if let isStarted = isStarted, isStarted {
            mContentView.alpha = 1.0
            dotView.backgroundColor = .red
        } else {
            mContentView.alpha = 0.6
            dotView.backgroundColor = normalColorText
        }
        
        numberLabel.text =  "\(location.seq ?? 0)."
        titleLabel.text =  "\(location.orderTypeName ?? "") #\(location.taskSeq ?? "")"
        addressLabel.text = location.locAddr
        
        
        timeLabel.text = "\(location.startTimeWindow ?? "") - \(location.endTimeWindow ?? "")"
        dateLabel.text = Date().toString(location.eptDt ?? "", "yyyy-MM-dd", "MMM dd")
        
        if let isFullData = isFullData, !isFullData {
            addressLabel.text = ""
            timeLabel.text = ""
            dateLabel.text = ""
        }
        
        guard let statusCode = location.routeLocationsStsCd,
        let status = OrderStatus(rawValue: statusCode) else {
            return
        }
        statusButton.typeStatusButton(status)
        if  statusCode.compare(OrderStatus.delivered.rawValue) == .orderedSame{
            mContentView.backgroundColor = finishColorView
            dotView.backgroundColor = finishColorText
            
            addressLabel.textColor = finishColorText
            timeLabel.textColor = finishColorText
            dateLabel.textColor = finishColorDateText
        } else {
            mContentView.backgroundColor = normalColorView
//            dotView.backgroundColor = normalColorText
            
            addressLabel.textColor = normalColorText
            timeLabel.textColor = normalColorText
            dateLabel.textColor = normalColorDateText

        }
    }
 */
}
