//
//  FilterDataListStatusCell.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 2/19/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

protocol FilterDataListStatusCellDelegate:AnyObject {
    func filterDataListStatusCell(cell: FilterDataListStatusCell, didSelect status:String, index:Int)

}

class FilterDataListStatusCell: UITableViewCell {
    
    @IBOutlet weak var btnStatus:UIButton?

    weak var delegate:FilterDataListStatusCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didSelectStatus(btn:UIButton) {
        var status = ""
        switch btn.tag {
        case 0:
            status = "OP"
        case 1:
            status = "IP"
        case 2:
            status = "DV"
        case 3:
            status = "CC"
        case 4:
            status = "UF"

        default:
            break
        }
        delegate?.filterDataListStatusCell(cell: self, didSelect: status, index: btn.tag)
    }
}
