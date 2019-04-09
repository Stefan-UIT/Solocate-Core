//
//  ContentCell.swift
//  DMSDriver
//
//  Created by Mach Van  Nguyen on 4/5/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class ContentCell: UITableViewCell {
    
    @IBOutlet weak var tfContent:UITextField?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
