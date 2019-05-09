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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
            /*
            use this method is do not work
            imvIcon?.setImageWithURL(url: Caches().user?.userInfo?.avatar_thumb,
                                     placeHolderImage: menuType?.normalIcon(),
                                     complateDownload: nil)
            imvIcon?.sd_setImage(with: URL(string: E(Caches().user?.userInfo?.avatar_thumb)),
                                     placeholderImage: menuType?.normalIcon(),
                                     options: [.refreshCached,.scaleDownLargeImages], completed: nil)
             */
            imvIcon?.setImage(withURL: E(Caches().user?.userInfo?.avatar_thumb),placeholderImage: menuType?.normalIcon())
        }else {
            imvIcon?.image = menuType?.normalIcon()
            lblTitle?.text = menuType?.title()
        }
        selectionStyle = .none;
    }
}
