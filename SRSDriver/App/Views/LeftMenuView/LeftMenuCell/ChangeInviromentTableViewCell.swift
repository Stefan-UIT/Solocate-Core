//
//  ChangeInviromentTableViewCell.swift
//  DMSDriver
//
//  Created by MrJ on 5/10/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class ChangeInviromentTableViewCell: BaseTableViewCell {

    @IBOutlet weak var enviromentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let type = DataManager.getEnviroment()
        switch type {
        case .DEMO:
            enviromentLabel.text = "Enviroment - Demo"
            break
        case.DEV:
            enviromentLabel.text = "Enviroment - Dev"
            break
        case .PRODUCT:
            enviromentLabel.text = "Enviroment - Product"

        }
    }
    
    override func loadData(_ data : Any) {
        if let text = data as? String {
            enviromentLabel.text = "Enviroment - \(text)"
        }
    }
}
