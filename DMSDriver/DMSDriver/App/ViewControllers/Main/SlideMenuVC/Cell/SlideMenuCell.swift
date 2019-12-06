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
    
    private var selectedType:MenuItemType?
    private var menuType:MenuItemType?


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configura(menuType:MenuItemType,selectedType:MenuItemType) {
        self.selectedType = selectedType
        self.menuType = menuType
        updateUI()
    }
  
    func updateUI() {
        vLine?.isHidden = (menuType != MenuItemType.LOGOUT)
        if menuType == selectedType {
            imvIcon?.tintColor = AppColor.mainColor
            lblTitle?.textColor = AppColor.mainColor
        }else{
            imvIcon?.tintColor = AppColor.grayBorderColor
            lblTitle?.textColor = AppColor.grayBorderColor
        }
        
        if menuType == .PROFILE{
            lblTitle?.text = Cache.shared.user?.userInfo?.userName
            lblSubtitle?.text = Cache.shared.userLogin?.email
            lblTitle?.textColor = AppColor.white
            lblSubtitle?.textColor = AppColor.white
            imvIcon?.setImage(withURL: E(Caches().user?.userInfo?.avatar_thumb),placeholderImage: menuType?.normalIcon())
        }else {
            imvIcon?.image = menuType?.normalIcon()
            lblTitle?.text = menuType?.title()
        }
        selectionStyle = .none;
    }
}
