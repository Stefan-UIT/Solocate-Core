//
//  ReasonSkipTableViewCell.swift
//  SRSDriver
//
//  Created by MrJ on 2/13/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit

class ReasonSkipTableViewCell: UITableViewCell {

    @IBOutlet weak var reasonLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
    }
    
    func loadData(_ reason: String) {
        reasonLabel.text = reason
    }
    
    func handleSelectedCell() {
        reasonLabel.backgroundColor = UIColor(hex: "#4CD493")
    }
    
    
    func handleNoSelectCell() {
        reasonLabel.backgroundColor = UIColor(hex: "#353A50")
    }
}
