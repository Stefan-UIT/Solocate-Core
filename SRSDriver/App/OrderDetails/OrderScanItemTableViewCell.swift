//
//  OrderScanItemTableViewCell.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 3/22/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class OrderScanItemTableViewCell: UITableViewCell {
    
  @IBOutlet weak var skuLabel: UILabel!
  @IBOutlet weak var quantityLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var barcodeLabel: UILabel!
  
  var orderItem: OrderItem! {
    didSet {
      skuLabel.text = orderItem.sku
      quantityLabel.text = "\(orderItem.qty)"
      descriptionLabel.text = orderItem.desc
      let status = OrderStatus(rawValue: orderItem.statusCode)!
      statusLabel.text = "(\(status.statusName))"
      barcodeLabel.text = orderItem.barcode
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
