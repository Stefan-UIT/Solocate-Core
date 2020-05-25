//
//  BusinessDetailHeaderView.swift
//  DMSDriver
//
//  Created by Trung Vo on 5/25/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import UIKit
protocol BusinessDetailHeaderViewDelegate: class {
    func didTouchOnAddButton()
}
    
class BusinessDetailHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var addButton: UIButton?
    @IBOutlet weak var titleLabel: UILabel?
    
    static let reuseIdentifier: String = String(describing: self)
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    weak var delegate: BusinessDetailHeaderViewDelegate?
    
    
    /*
     @IBOutlet weak var addButton: UIButton!
     // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBAction func onAddButtonTouchUp(_ sender: UIButton) {
        self.delegate?.didTouchOnAddButton()
    }
    
}
