//
//  PurchaseOrderDetailTableViewCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 12/16/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit


class PurchaseOrderDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var contentLabel: UILabel?
    
    var purchaseOrderDetailItem: OrderDetailInforRow! {
        didSet {
            nameLabel?.text = purchaseOrderDetailItem.title
            contentLabel?.text = purchaseOrderDetailItem.content
            //            contentLabel?.textColor = orderDetailItem.isHighlight ? AppColor.buttonColor : AppColor.black
            if let color = purchaseOrderDetailItem.textColor {
                contentLabel?.textColor = color
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel?.numberOfLines = 0
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
