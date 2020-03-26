//
//  DropDownTableViewCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/18/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import UIKit

class DropDownTableViewCell: UITableViewCell {
    @IBOutlet weak var resultLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ item: String) {
        resultLabel.text = item
    }
    
}
