//
//  FilterDataTypeRowCell.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 2/19/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

protocol FilterDataTypeRowCellDelegate:AnyObject {
    func filterDataTypeRowCell(cell:FilterDataTypeRowCell, didSelectType type:String)
}

class FilterDataTypeRowCell: UITableViewCell {
    
    @IBOutlet weak var btnPickup:UIButton?
    @IBOutlet weak var btnDelivery:UIButton?

    weak var delegate:FilterDataTypeRowCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didSelectType(btn:UIButton){
        let tag = btn.tag
        let type = tag == 0 ? "Pickup" : "Delivery"
        delegate?.filterDataTypeRowCell(cell: self, didSelectType: type)
    }
}
