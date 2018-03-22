//
//  OrderItemsTableViewCell.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 3/22/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class OrderItemsTableViewCell: UITableViewCell {
  
  var didClickScanButton:(() -> Void)?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  @IBAction func scanCode(_ sender: UIButton) {
    didClickScanButton?()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
