//
//  FilterDataListHeaderCell.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 2/19/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

protocol FilterDataListHeaderCellDelegate:AnyObject {
    func filterDataListHeaderCell(cell:FilterDataListHeaderCell, didSelectHeader:UIButton);
}

class FilterDataListHeaderCell: UITableViewHeaderFooterView {
    
    @IBOutlet weak var lblTitle:UILabel?
    @IBOutlet weak var imvIcon:UIImageView?
    
    weak var delegate:FilterDataListHeaderCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction func onbtnClickHeader(btn:UIButton){
        delegate?.filterDataListHeaderCell(cell: self, didSelectHeader: btn)
    }
}
