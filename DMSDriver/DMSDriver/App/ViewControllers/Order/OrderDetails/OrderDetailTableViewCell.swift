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
//      lineView?.isHidden = (orderDetailItem.type == .description)
//      if orderDetailItem.type == .address {
//        iconImgView?.image = UIImage(named: "map")
//        iconImgView?.isHidden = false
//      }
//      else if orderDetailItem.type == .phone {
//        iconImgView?.image = UIImage(named: "phone")
//        iconImgView?.isHidden = false
//      }
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

enum OrderDetailType {
    case hour
    case date
    case certificateNumber
    case clientName
    case customerName
    case type
    case urgency
    case doubleType
    case packagesNumber
    case cartonsNumber
    case surfacesNumber
    case afternoon
    case vehicle
    case fromtodayToTomorrow
    case collectionFromCompany
    case startingStreet
    case startingCity
    case transferToCompany
    case destinationStreet
    case destinationCity
    case standby
    case barcode
    case collectCall
    case status
    case failureCause
    case comments
    case certificateNumber_client
    case executionTime
    case receiverName
    case secondReceiverName
    case message
}

struct OrderDetailInforRow {
  var type: OrderDetailType
  var name: String
  var content: String = ""
  
    init(_ type: OrderDetailType, _ content:String) {
        self.type = type
        self.content = content
        
        switch type {
        case .hour:
          name = "Hour".localized
        case .date:
          name = "Date".localized
        case .certificateNumber:
          name = "Certificate number".localized
        case .clientName:
          name = "Client name".localized
        case .customerName:
          name = "Customer name".localized
        case .type:
            name = "Type".localized
        case .urgency:
            name = "Urgency".localized
        case .doubleType:
            name = "Double type".localized
        case .packagesNumber:
            name = "Packages number".localized
        case .cartonsNumber:
            name = "Cartons number".localized
        case .surfacesNumber:
            name = "Surfaces number".localized
        case .afternoon:
            name = "Afternoon".localized
        case .vehicle:
            name = "Vehicle".localized
        case .fromtodayToTomorrow:
            name = "From today to tomorrow".localized
        case .collectionFromCompany:
            name = "Collection fromn company".localized
        case .startingCity:
            name = "Starting city".localized
        case .transferToCompany:
            name = "Transfer to company".localized
        case .destinationStreet:
            name = "Destination street".localized
        case .destinationCity:
            name = "Transfer to company".localized
        case .standby:
            name = "Standby".localized
        case .barcode:
            name = "Barcode".localized
        case .collectCall:
            name = "CollecCall".localized
        case .status:
            name = "Status".localized
        case .failureCause:
            name = "FailureCause".localized
        case .comments:
            name = "Comments".localized
        case .certificateNumber_client:
            name = "Certificate number (Client)".localized
        case .executionTime:
            name = "Execution time".localized
        case .receiverName:
            name = "Receiver name".localized
        case .secondReceiverName:
            name = "Second receiver name".localized
        case .startingStreet:
            name = "Starting street".localized
        case .message:
            name = "Message".localized
        }
    }
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


