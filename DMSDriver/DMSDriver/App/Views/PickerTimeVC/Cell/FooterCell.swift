//
//  FooterCell.swift
//  DMSDriver
//
//  Created by Mach Van  Nguyen on 4/5/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
protocol FooterCellDelegate:AnyObject {
    func footerCell(footerCell:FooterCell,hasYes:Bool)
}


class FooterCell: UITableViewCell {
    @IBOutlet weak var btnDone:UIButton?
    @IBOutlet weak var btnCancel:UIButton?
    
    weak var delegate:FooterCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //_vButton.clipsToBounds = YES;
        //[_vButton setBottomCorner:YES];
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onBtnDone(btn:UIButton){
        delegate?.footerCell(footerCell: self, hasYes: true)
    }
    
    
    @IBAction func onBtnCancel(btn:UIButton){
        delegate?.footerCell(footerCell: self, hasYes: false)
    }
}
