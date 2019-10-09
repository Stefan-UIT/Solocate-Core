//
//  RentingOrderDetailTableViewCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 9/24/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit


class RentingOrderDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var truckTypeLabel: UILabel!
    @IBOutlet weak var truckLabel: UILabel!
    @IBOutlet weak var trailerTankerTypeLabel: UILabel!
    @IBOutlet weak var tankerLabel: UILabel!
    @IBOutlet weak var trailerTankerType2Label: UILabel!
    @IBOutlet weak var tanker2Label: UILabel!
    @IBOutlet weak var skulistLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var trailerTankerType2View: UIView!
    @IBOutlet weak var tanker2View: UIView!
    
    var rentingOrderDetail:RentingOrder.RentingOrderDetail!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCellWithRentingOrderDetail(_ rentingOrderDetail: RentingOrder.RentingOrderDetail) {
        trailerTankerType2View.isHidden = true
        tanker2View.isHidden = true
        truckTypeLabel.text = rentingOrderDetail.truckType?.name
        truckLabel.text = "\(rentingOrderDetail.truck?.id ?? 0)"
        trailerTankerTypeLabel.text = rentingOrderDetail.tanker?.tankerType?[0].name
        tankerLabel.text = rentingOrderDetail.tanker?.tanker?[0].plateNum
        if rentingOrderDetail.tanker?.tankerType?.count > 1 {
            trailerTankerType2View.isHidden = false
            trailerTankerType2Label.text = rentingOrderDetail.tanker?.tankerType?[1].name
            
        }
        if rentingOrderDetail.tanker?.tanker?.count > 1 {
            tanker2View.isHidden = false
            tanker2Label.text = rentingOrderDetail.tanker?.tanker?[1].plateNum
        }
        skulistLabel.text = rentingOrderDetail.skulist
        driverLabel.text = rentingOrderDetail.driver?.userName
    }
    
}
