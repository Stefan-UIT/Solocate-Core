//
//  PickerTypeListCell.swift
//  VSip-iOS
//
//  Created by machnguyen_uit on 7/25/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit

class PickerTypeListCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle:UILabel?
    @IBOutlet weak var lblSubtitle:UILabel?
    @IBOutlet weak var imgIcon:UIImageView?

    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
