//
//  SlideMenuCell.swift
//  DMSDriver
//
//  Created by phunguyen on 7/4/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class SlideMenuCell: UITableViewCell {
  
    @IBOutlet weak var imvIcon:UIImageView?
    @IBOutlet weak var lblTitle:UILabel?
    @IBOutlet weak var lblSubtitle:UILabel?
    @IBOutlet weak var vLine:UIView?

    var menuType:MenuItemType!{
        didSet{
            updateUI()
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
  
    func updateUI() {
        imvIcon?.image = menuType.normalIcon()
        lblTitle?.text = menuType.title()
        if menuType == .PROFILE{
          lblTitle?.text = Cache.shared.user?.userInfo?.userName
          lblSubtitle?.text = Cache.shared.userLogin?.email
        }
        
        vLine?.isHidden = (menuType != MenuItemType.LOGOUT)
    }
}
