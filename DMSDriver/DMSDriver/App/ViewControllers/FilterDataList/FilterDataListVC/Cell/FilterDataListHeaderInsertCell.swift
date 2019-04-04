//
//  FilterDataListHeaderInsertCell.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 2/19/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class FilterDataListHeaderInsertCell: UITableViewHeaderFooterView {
    @IBOutlet weak var lblTitle:UILabel?
    @IBOutlet weak var tfContent:UITextField?
    @IBOutlet weak var imvIcon:UIImageView?
    @IBOutlet weak var vContent:UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.perform(#selector(updateUI), with: nil, afterDelay: 0.025)
    }
    
    @objc func updateUI() {
        vContent?.roundedCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], 10)
        vContent?.layer.borderWidth = 1;
        vContent?.layer.borderColor = AppColor.mainColor.cgColor
    }
    
    func setPlaceholder(_ text:String) {
        tfContent?.placeholder(text: text, color: AppColor.grayBorderColor)
    }
}
