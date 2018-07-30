//
//  OrderDetailTableViewCell.swift
//  SRSDriver
//
//  Created by phunguyen on 3/16/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class OrderDetailTableViewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel?
  @IBOutlet weak var contentLabel: UILabel?
  @IBOutlet weak var iconImgView: UIImageView?
  @IBOutlet weak var lineView: UIView?

  
  var orderDetailItem: OrderDetailInforRow! {
    didSet {
      nameLabel?.text = orderDetailItem.name
      contentLabel?.text = orderDetailItem.content
      iconImgView?.isHidden = true
      lineView?.isHidden = (orderDetailItem.type == .description)
      if orderDetailItem.type == .address {
        iconImgView?.image = UIImage(named: "map")
        iconImgView?.isHidden = false
      }
      else if orderDetailItem.type == .phone {
        iconImgView?.image = UIImage(named: "phone")
        iconImgView?.isHidden = false
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    contentLabel?.numberOfLines = 0
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}



struct OrderDetailInforRow {
  var type: OrderDetailType
  var name: String
  var content: String = ""
  
    init(_ type: OrderDetailType, _ content:String) {
        self.type = type
        self.content = content
        
        switch type {
        case .orderId:
          name = "Order Id"
        case .status:
          name = "Status".localized
        case .type:
          name = "Type".localized
        case.reference:
          name = "Order Ref".localized
        case .deliveryDate:
          name = "Expected Date".localized
        case .startTime:
            name = "Window Start Time".localized
        case .endTime:
            name = "Window End Time".localized
        case .serviceTime:
            name = "Service Time".localized
        case .seq:
            name = "SEQ".localized
        case .pallets:
            name = "Pallets".localized
        case .cases:
            name = "Cases".localized
        case .customerName:
          name = "Contact Name".localized
        case .phone:
          name = "Phone".localized
        case .address:
          name = "Address".localized
        case .description:
          name = "Description".localized
        case .reason:
          name = "Reason".localized
        case .message:
          name = "Message".localized
        }
  }
}


enum OrderDetailType {
  case orderId
  case status
  case type
  case reference
  case deliveryDate
  case startTime
  case endTime
  case serviceTime
  case seq
  case pallets
  case cases
  case customerName
  case phone
  case address
  case description
  case reason
  case message
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
      return "New".localized
    case .inprogress:
      return "In Progress".localized
    case .delivered:
      return "Finished".localized
    case .cancel:
      return "Cancelled".localized
    case .pickedUp:
        return "Picked Up".localized
    case .missingInTruck:
        return "Missing in Trunk".localized
    case .missingAnPickUP:
        return "Missing at Pick-up".localized
    }
  }
}


