//
//  FilterByDatePopupCustomCell.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 3/5/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

protocol FilterByDatePopupCustomCellDelegate:AnyObject {
    func filterByDatePopupCustomCell(cell:FilterByDatePopupCustomCell, didSelectCheckCustom btn:UIButton)
}

class FilterByDatePopupCustomCell: UITableViewCell {
    
    @IBOutlet weak var btnCheck:UIButton?
    @IBOutlet weak var lblName:UILabel?
    @IBOutlet weak var lblDay:UILabel?
    @IBOutlet weak var btnCustom:UIButton?
    @IBOutlet weak var lineView:UIView?

    
    var delegate:FilterByDatePopupCustomCellDelegate?


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onCheckBtnCustom(btn:UIButton){
        delegate?.filterByDatePopupCustomCell(cell: self, didSelectCheckCustom: btn)
    }
}
