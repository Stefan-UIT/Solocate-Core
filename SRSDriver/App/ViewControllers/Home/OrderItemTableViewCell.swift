//
//  OrderItemTableViewCell.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class OrderItemTableViewCell: UITableViewCell {
  
  @IBOutlet weak var lblTitle: UILabel?
  @IBOutlet weak var lblSubtitle: UILabel?
  @IBOutlet weak var lblDate: UILabel?
  @IBOutlet weak var btnStatus: UIButton?
  @IBOutlet weak var btnNumber: UIButton?

  
  @IBOutlet weak var vContent: UIView?

  var order: Order! {
    didSet {
        updateCell()
    }
  }
    
  func updateCell() {
      lblTitle?.text = "\(order.sequence) - \(order.orderReference)"
      lblSubtitle?.text = order.orderType
      let status = OrderStatus(rawValue: order.statusCode) ?? OrderStatus.open
      btnStatus?.setTitle("\(status.statusName)", for: .normal)
      btnStatus?.borderWidth = 1.0;
      btnStatus?.borderColor = AppColor.grayColor;
      lblDate?.text = order.deliveryDate
      vContent?.cornerRadius = 4.0;
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
