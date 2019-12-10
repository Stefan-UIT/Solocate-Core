//
//  LocationDetailViewCell.swift
//  DMSDriver
//
//  Created by Seldat on 5/10/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class LocationDetailViewCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet weak var btnClose:UIButton?
    @IBOutlet weak var lblTitle:UILabel?
    @IBOutlet weak var lblSubTitle:UILabel?
    @IBOutlet weak var lblSubTitle2:UILabel?
    @IBOutlet weak var lblLocationName: UILabel?
    @IBOutlet weak var lblExpectedTime: UILabel?
    @IBOutlet weak var lblDate: UILabel?
    @IBOutlet weak var vContent: UIView?

    //MARK: - View Life Cycles
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
