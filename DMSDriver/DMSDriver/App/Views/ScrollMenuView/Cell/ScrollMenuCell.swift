//
//  ScrollMenuCell.swift
//  Sel2B
//
//  Created by machnguyen_uit on 6/14/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class ScrollMenuCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle:UILabel?
    @IBOutlet weak var lblSubTitle:UILabel?
    @IBOutlet weak var vContent:UIView?

    var isSelect:Bool = false;
    
    var item:MenuItem?{
        didSet{
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupUI()
    }

    
    func setupUI() {
//        lblTitle?.font = AppFont.fontbold(size: 15);
//        lblSubTitle?.font = AppFont.fontbold(size: 25);
//        vContent?.setBorder(borderWidth: 1, color: AppColor.grayColor)
    }
    
    func configura(item:MenuItem, isSelect:Bool)  {
        self.isSelect = isSelect
        self.item = item
    }
    
    func updateUI()  {
        lblTitle?.text = E(item?.name).localized
        
        if isSelect == true {
            lblTitle?.textColor = AppColor.white;
            vContent?.backgroundColor = AppColor.mainColor;
            
        }else {
            lblTitle?.textColor = AppColor.mainColor
            vContent?.backgroundColor = AppColor.white;
        }
    }
}
