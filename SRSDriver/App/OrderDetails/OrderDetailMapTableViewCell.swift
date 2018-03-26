//
//  OrderDetailMapTableViewCell.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 3/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class OrderDetailMapTableViewCell: UITableViewCell {
  @IBOutlet weak var instructionsLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var instructionIcon: UIImageView!
  
  var step: DirectionStep! {
    didSet {
      instructionsLabel.from(html: step.instructions)
      distanceLabel.text = step.distance.text
      instructionIcon.image = UIImage(named: step.maneuver)
    }
  }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
