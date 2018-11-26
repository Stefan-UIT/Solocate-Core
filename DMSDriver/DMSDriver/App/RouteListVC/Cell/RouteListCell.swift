//
//  RouteListCell.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class RouteListCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle:UILabel?
    @IBOutlet weak var lblSubtitle:UILabel?
    @IBOutlet weak var lblRouteNumber:UILabel?
    @IBOutlet weak var lblTotal:UILabel?
    @IBOutlet weak var lblStartTime:UILabel?
    @IBOutlet weak var lblEndTime:UILabel?
    @IBOutlet weak var lblWarehouse:UILabel?
    @IBOutlet weak var lblDriver:UILabel?

    @IBOutlet weak var btnStatus:UIButton?
    @IBOutlet weak var btnColor:UIButton?
  
    @IBOutlet weak var vContent:UIView?



    override func awakeFromNib() {
        super.awakeFromNib()
      
        vContent?.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
