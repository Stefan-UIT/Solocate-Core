//
//  OrderDetailTableViewCell.swift
//  SRSDriver
//
//  Created by phunguyen on 3/16/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class OrderDetailTableViewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var iconImgView: UIImageView!
  
  var orderDetailItem: OrderDetailItem! {
    didSet {
      nameLabel.text = orderDetailItem.name
      contentLabel.text = orderDetailItem.content
      iconImgView.isHidden = true
      if orderDetailItem.type == .address {
        iconImgView.image = UIImage(named: "map")
        iconImgView.isHidden = false
      }
      else if orderDetailItem.type == .phone {
        iconImgView.image = UIImage(named: "phone")
        iconImgView.isHidden = false
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    contentLabel.numberOfLines = 0
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}



struct OrderDetailItem {
  var type: OrderDetailType
  var name: String
  var content: String = ""
  var items = [OrderItem]()
  
  init(_ type: OrderDetailType) {    
    self.type = type
    switch type {
    case .reference:
      name = "Order Reference"
    case .status:
      name = "Status"
    case .deliveryDate:
      name = "Delivery Date"
    case .customerName:
      name = "Delivery Contact Name"
    case .phone:
      name = "Delivery Contact Phone"
    case .address:
      name = "Delivery Address"
    case .description:
      name = "Description"
    case .items:
      name = "Items"
    }
  }
}


enum OrderDetailType {
  case reference
  case status
  case deliveryDate
  case customerName
  case phone
  case address
  case description
  case items
}

enum OrderStatus: String {
  case open = "OP"
  case inprogress = "IP"
  case delivered = "DV"
  case cancel = "CC"
  
  var statusName: String {
    switch self {
    case .open:
      return "orders_open".localized
    case .inprogress:
      return "orders_in_progress".localized
    case .delivered:
      return "orders_delivered".localized
    case .cancel:
      return "orders_cancelled".localized
    }
  }
  
  
  
  
}


