//
//  RouteMessageTableViewCell.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 4/2/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class RouteMessageTableViewCell: UITableViewCell {
  
  @IBOutlet weak var authorLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var createdAt: UILabel!
  
  var alertDetail: AlertDetailModel? {
    didSet {
        contentLabel.text = alertDetail?.alertMsg
    }
  }
  var message: Message! {
    didSet {
      authorLabel.text = message.sendFrom.length > 0 ? "\(message.sendFrom)" : "Me"
      contentLabel.text = "\(message.content)"
      createdAt.text = "\(message.createdAt)"
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
}
