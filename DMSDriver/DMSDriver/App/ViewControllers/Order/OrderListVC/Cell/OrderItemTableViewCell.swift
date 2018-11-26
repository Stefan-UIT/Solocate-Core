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
    
      let displayDateTimeVN = DateFormatter.displayDateTimeVN
      let startDate = DateFormatter.serverDateFormater.date(from: order.startTime)
      let endDate = DateFormatter.serverDateFormater.date(from: order.endTime)
    
      lblTitle?.text = "\(order.orderReference)"
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
      lblFromdate?.text = (startDate != nil) ? displayDateTimeVN.string(from: startDate!) : ""
      lblTodate?.text = (endDate != nil) ? displayDateTimeVN.string(from: endDate!) : ""

      let status = OrderStatus(rawValue: order.statusCode) ?? OrderStatus.open
      btnStatus?.setTitle("\(status.statusName)", for: .normal)
      btnStatus?.setTitleColor(order.colorStatus, for: .normal)
      btnStatus?.borderWidth = 1.0;
      btnStatus?.layer.cornerRadius = 3.0;
      btnStatus?.borderColor = order.colorStatus;
      vContent?.cornerRadius = 4.0;
      vContent?.backgroundColor = order.backgroundCities
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
