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
    @IBOutlet weak var vContent: UIView?

    
    func configura(_ key:String,_ value:String, _ isCornerRadiusButtom:Bool = false)  {
        lblKey?.text = key
        lblValue?.text = value
        if isCornerRadiusButtom {
            vContent?.roundCornersLRB()
        }
    }
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.selectionStyle = .none
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
