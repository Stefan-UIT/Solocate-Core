//
//  ProfileCell.swift
//  DMSDriver
//
//  Created by phunguyen on 7/4/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel?
    @IBOutlet weak var tfContent:UITextField?
    @IBOutlet weak var imvAvartar:UIImageView?
    @IBOutlet weak var btnEdit:UIButton?

  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
