//
//  PackageTableViewCell.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 4/6/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class PackageTableViewCell: UITableViewCell {
    
  @IBOutlet weak var lblKey: UILabel?
  @IBOutlet weak var lblValue: UILabel?
    
  func configura(_ key:String,_ value:String)  {
    lblKey?.text = key
    lblValue?.text = value
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
