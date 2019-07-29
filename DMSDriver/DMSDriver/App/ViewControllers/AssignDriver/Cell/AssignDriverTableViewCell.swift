//
//  AssignDriverTableViewCell.swift
//  DMSDriver
//
//  Created by Trung Vo on 7/29/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class AssignDriverTableViewCell: UITableViewCell {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(driver:Driver) {
        nameLabel.text = driver.userName ?? "-"
        phoneLabel.text = driver.phone
        emailLabel.text = driver.email
        
    }

}
