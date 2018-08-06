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
  @IBOutlet weak var lblStore: UILabel?
  @IBOutlet weak var lblShop: UILabel?
  @IBOutlet weak var lblExpectedTime: UILabel?
  @IBOutlet weak var lblRecordsFrom: UILabel?
  @IBOutlet weak var lblFromdate: UILabel?
  @IBOutlet weak var lblTodate: UILabel?
  @IBOutlet weak var lblDeliverynumber: UILabel?
  @IBOutlet weak var lblUrgency: UILabel?
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
      lblDeliverynumber?.text = order.orderReference
      lblStore?.text =  order.storeName
      if Locale.current.languageCode == "he" {
        lblUrgency?.text = order.urgent_type_name_hb
        lblSubtitle?.text = order.order_type_name_hb

      }else {
        lblUrgency?.text = order.urgent_type_name_en
        lblSubtitle?.text = order.order_type_name
      }
      lblUrgency?.textColor = order.colorUrgent
      lblExpectedTime?.text = "\(order.startTime) ~ \(order.endTime)"
      lblTodate?.text = order.deliveryDate;

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
