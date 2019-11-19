//
//  LocationDetailViewCell.swift
//  DMSDriver
//
//  Created by Seldat on 5/10/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class LocationDetailViewCell: UITableViewCell {
    
    @IBOutlet weak var btnClose:UIButton?
    @IBOutlet weak var lblTitle:UILabel?
    @IBOutlet weak var lblSubTitle:UILabel?
    @IBOutlet weak var lblSubTitle2:UILabel?
    @IBOutlet weak var lblLocationName: UILabel?
    @IBOutlet weak var lblExpectedTime: UILabel?
    @IBOutlet weak var lblDate: UILabel?
    @IBOutlet weak var vContent: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
