//
//  MapRouteDetailTableViewCell.swift
//  SRSDriver
//
//  Created by MrJ on 1/22/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit
import GoogleMaps

class MapRouteDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var mapView: GMSMapView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
    }
    
    
    func loadData(_ locations: [LocationToDrawMapModel]?) {
        mapView?.drawMap(locations)
    }
 
}
