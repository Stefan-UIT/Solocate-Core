//
//  PackageTableViewCell.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 4/6/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class PackageTableViewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var totalLabel: UILabel!
  @IBOutlet weak var barcodeLabel: UILabel!
  
  var item: OrderItem! {
    didSet {
      nameLabel.text = item.name
      totalLabel.text = item.total > 0 ? "\(item.total)" : "-"
      barcodeLabel.text = item.barcode
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
