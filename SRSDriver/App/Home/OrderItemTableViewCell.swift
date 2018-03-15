//
//  OrderItemTableViewCell.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class OrderItemTableViewCell: UITableViewCell {
  @IBOutlet weak var orderReference: UILabel!
  @IBOutlet weak var orderStatus: UILabel!
  @IBOutlet weak var deliveryAddress: UILabel!
  @IBOutlet weak var deliveryDate: UILabel!
  @IBOutlet weak var cellContainerView: UIView!

  var order: Order! {
    didSet {
      orderReference.text = "\(order.sequence). \(order.orderReference)"
      orderStatus.text = "\(order.statusName)"
      deliveryAddress.text = "\(order.deliveryAdd)"
      deliveryDate.text = "\(order.deliveryDate) - (\(order.timeWindowName))"
      let color = order.statusCode == "DV" ? "#757575" : "#FFFFFF"
      cellContainerView.backgroundColor = UIColor(hex: color)
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
