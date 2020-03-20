//
//  BusinessOrderConfirmTableViewCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/19/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import UIKit

class BusinessOrderConfirmTableViewCell: UITableViewCell {
    @IBOutlet weak var submitView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        submitView.backgroundColor = AppColor.greenColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
