//
//  HistoryNotifyCell.swift
//  VSip-iOS
//
//  Created by machnguyen_uit on 9/4/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit

protocol HistoryNotifyCellDelegate:AnyObject {
    func didSelectResolveAlert(cell:HistoryNotifyCell, btn:UIButton)
}

class HistoryNotifyCell: UITableViewCell {
    
    @IBOutlet weak var vBackgound:UIView?
    @IBOutlet weak var imvIcon:UIImageView?
    @IBOutlet weak var lblTitle:UILabel?
    @IBOutlet weak var lblSubTitle:UILabel?
    @IBOutlet weak var lblDate:UILabel?
    @IBOutlet weak var btnStatus:UIButton?
    @IBOutlet weak var btnResolve:UIButton?
    @IBOutlet weak var csHeightViewAction:NSLayoutConstraint?

    

    var delegate:HistoryNotifyCellDelegate?
    
    
    func setStyleButtonStatus(_ alert:AlertModel) {
        btnStatus?.layer.cornerRadius = 5.0
        btnStatus?.layer.masksToBounds = true
        btnStatus?.clipsToBounds = true
        btnStatus?.borderWidth = 1
        btnStatus?.borderColor =  alert.colorStatus
        btnStatus?.setTitleColor(alert.colorStatus, for: .normal)
        btnStatus?.setTitle(alert.statusName?.localized, for: .normal)
    }
    
    //MARK: - ACTION
    @IBAction func onbtnClickResolves(btn:UIButton)  {
        delegate?.didSelectResolveAlert(cell: self, btn: btn)
    }
}
