//
//  AssignDriverTableViewCell.swift
//  DMSDriver
//
//  Created by Trung Vo on 7/29/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class AssignTruckTableViewCell: UITableViewCell {

    @IBOutlet weak var truckTypeLabel: UILabel!
    @IBOutlet weak var maxLoadLabel: UILabel!
    @IBOutlet weak var maxVolumeLabel: UILabel!
    @IBOutlet weak var maxFloorLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(truck:Truck) {
        nameLabel.text = truck.name
        truckTypeLabel.text = Slash(truck.type?.name)
        maxLoadLabel.text = "\(truck.maxLoad)"
        maxVolumeLabel.text = "\(truck.maxVolume)"
        maxFloorLabel.text = "\(truck.maxFloor)"
    }
}
