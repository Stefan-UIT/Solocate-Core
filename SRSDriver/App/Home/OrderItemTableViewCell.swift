//
//  OrderItemTableViewCell.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class OrderItemTableViewCell: UITableViewCell {
  
  @IBOutlet weak var orderType: UILabel!
  @IBOutlet weak var orderReference: UILabel!
  @IBOutlet weak var orderStatus: UILabel!
  @IBOutlet weak var deliveryAddress: UILabel!
  @IBOutlet weak var deliveryDate: UILabel!
  @IBOutlet weak var cellContainerView: UIView!

  var order: Order! {
    didSet {
      orderReference.text = "\(order.sequence) - \(order.orderReference)"
      let status = OrderStatus(rawValue: order.statusCode) ?? OrderStatus.open
      orderStatus.text = "(\(status.statusName))"
      deliveryAddress.text = "\(order.deliveryAdd)"
      let deliveryDateString = order.timeWindowName.length > 0 ? "\(order.deliveryDate) - (\(order.timeWindowName))" : "\(order.deliveryDate)"
      deliveryDate.text = deliveryDateString
      let color = order.statusCode == "DV" ? AppColor.highLightColor : UIColor(hex: "#FFFFFF")
      cellContainerView.backgroundColor = color
      orderType.text = order.orderType
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
