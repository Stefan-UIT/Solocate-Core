//
//  FilterDataListFooterView.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 2/19/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

protocol FilterDataListFooterViewDelegate:AnyObject {
    func filterDataListFooterView(view:FilterDataListFooterView, didSelectSearch:UIButton)
}

class FilterDataListFooterView: UIView {
    
    weak var delegate:FilterDataListFooterViewDelegate?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func onbtnClickSearch(btn:UIButton) {
        delegate?.filterDataListFooterView(view: self, didSelectSearch: btn)
    }
}
