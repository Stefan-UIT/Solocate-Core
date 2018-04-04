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
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
