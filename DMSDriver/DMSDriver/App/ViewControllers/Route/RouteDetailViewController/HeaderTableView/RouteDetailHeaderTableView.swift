//
//  HeaderRouteDetailTableView.swift
//  SRSDriver
//
//  Created by MrJ on 1/22/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit

protocol RouteDetailHeaderTableViewDelegate: class {
    func routeDetailHeaderTableView(_ view: RouteDetailHeaderTableView, _ valueSelected: RouteDetailHeaderTableView.TypeSelected)
}

class RouteDetailHeaderTableView: BaseView {
    
    enum TypeSelected: Int {
        case MAP = 0
        case STOPS_FULL = 1
        case STOPS_SHORT = 2
    }
    // MARK: IBOutlet
    
    @IBOutlet weak var routeIDLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stopsLabel: UILabel!
    
    
    @IBOutlet weak var changeTypeListButton: UIButton!
    @IBOutlet weak var bottomConstraintSegmentControl: NSLayoutConstraint!
    
    // MARK: Variables
    weak var delegate: RouteDetailHeaderTableViewDelegate? = nil
    private var bottomConstraintSegmentControlValue : CGFloat = 0.0
    // MARK: Init
    override init() {
        super.init()
        changeTypeListButton.isHidden = true
        bottomConstraintSegmentControlValue = bottomConstraintSegmentControl.constant
        bottomConstraintSegmentControl.constant = 0.0
        
        routeIDLabel.text       = "..."
        statusButton.setTitle("", for: .normal)
        startTimeLabel.text     = "..."
        durationLabel.text      = "..."
        distanceLabel.text      = "..."
        stopsLabel.text         = "..."
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Function
    func loadData(_ route: Route) {
        /*
        routeIDLabel.text       = "Route #\(route.id ?? 0)"
        if let statusStr = route.routeStsCd,
            let status = OrderStatus(rawValue: statusStr) {
            statusButton.typeStatusButton(status)
        }
        startTimeLabel.text     = "\(route.estStartTime ?? "") - \(route.date ?? "")"
        durationLabel.text      = route.totTimeEst
        distanceLabel.text      = route.totDist ?? ""
        stopsLabel.text         = "\(route.totStop ?? 0) STOPS"
         */
    }
    
    
    func handeValueSelected(_ valueSelected: TypeSelected) {
        switch valueSelected {
        case .MAP:
            changeTypeListButton.isHidden = true
            bottomConstraintSegmentControl.constant = 0.0
            break
        case .STOPS_FULL:
            changeTypeListButton.isHidden = false
            bottomConstraintSegmentControl.constant = bottomConstraintSegmentControlValue
            break
        case .STOPS_SHORT:
            changeTypeListButton.isHidden = false
            bottomConstraintSegmentControl.constant = bottomConstraintSegmentControlValue
            break
        }
        if delegate != nil {
            delegate?.routeDetailHeaderTableView(self, valueSelected)
        }
    }
    
    // MARK: Action
    @IBAction func editingChangedSegmentControlAction(_ sender: UISegmentedControl) {
        if let valueSelected = TypeSelected(rawValue: sender.selectedSegmentIndex) {
            handeValueSelected(valueSelected)
        }
    }
    
    @IBAction func changeTypeListButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            handeValueSelected(.STOPS_SHORT)
        } else {
            handeValueSelected(.STOPS_FULL)
        }

    }
}
