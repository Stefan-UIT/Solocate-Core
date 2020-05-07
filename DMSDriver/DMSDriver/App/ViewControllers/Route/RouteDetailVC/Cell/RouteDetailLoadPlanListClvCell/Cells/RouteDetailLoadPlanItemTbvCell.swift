//
//  RouteDetailLoadPlanItemTbvCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/27/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import UIKit

class RouteDetailLoadPlanItemTbvCell: UITableViewCell {

    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var skuLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureLiquid(_ detail: Compartment.Detail) {
        orderLabel.text = "order".localized + " " + Slash(detail.pivot?.shippingOrder?.companySeqID)
//        skuLabel.text = "sku".localized + " " + IntSlash(detail.pivot?.sku_id)
        skuLabel.text = detail.name
        unitLabel.text = IntSlash(detail.quantity)
        
    }
    
    func configurePacked(_ detail: Compartment.Detail) {
        orderLabel.text = "order".localized + " " + Slash(detail.pivot?.shippingOrder?.companySeqID)
        skuLabel.text = detail.name
        unitLabel.text = Slash(detail.seq)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
