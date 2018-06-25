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
      name = "order_detail_order_reference".localized
    case .status:
      name = "order_detail_status".localized
    case .type:
      name = "order_detail_order_type".localized
    case .deliveryDate:
      name = "order_detail_expected_date".localized
    case .customerName:
      name = "order_detail_contact_name".localized
    case .phone:
      name = "order_detail_phone".localized
    case .address:
      name = "order_detail_delivery_address".localized
    case .description:
      name = "order_detail_description".localized
    case .items:
      name = "items".localized
    }
  }
}


enum OrderDetailType {
  case reference
  case status
  case type
  case deliveryDate
  case customerName
  case phone
  case address
  case description
  case items
}

enum OrderStatus: String {
  case open = "OP"
  case pickedUp = "PU"
  case delivered = "DV"
  case inprogress = "IP"
  case missingInTruck = "MT"
  case missingAnPickUP = "MP"
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
        
    case .pickedUp:
        return "picked_up".localized
    case .missingInTruck:
        return "orders_missing_in_truck".localized
    case .missingAnPickUP:
        return "orders_missing_at_pick_up".localized
    }
  }
}


