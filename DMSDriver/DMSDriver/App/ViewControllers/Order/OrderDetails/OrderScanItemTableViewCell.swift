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
  @IBOutlet weak var coolerName: UILabel!
  @IBOutlet weak var beaconId: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var quantityLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var barcodeLabel: UILabel!
  @IBOutlet weak var qtyStackView: UIStackView!
    
  var orderItem: OrderItem! {
    didSet {
      skuLabel.text = orderItem.sku
      /* Added by Hoang Trinh for Masof - Begin */
      coolerName.text = orderItem.name
      beaconId.text = "- \(orderItem.bearconId)"
      
      /* Added by Hoang Trinh for Masof - End */
      quantityLabel.text = "\(orderItem.qty)"
      descriptionLabel.text = orderItem.desc
      let status = StatusOrder(rawValue: orderItem.statusCode)!
      statusLabel.text = "(\(status.statusName))"
      barcodeLabel.text = orderItem.barcode
    }
  }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        qtyStackView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
