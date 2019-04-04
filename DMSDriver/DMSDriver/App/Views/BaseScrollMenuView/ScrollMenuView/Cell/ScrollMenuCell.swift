//
//  ScrollMenuCell.swift
//  Sel2B
//
//  Created by machnguyen_uit on 6/14/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class ScrollMenuCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle:UILabel?
    @IBOutlet weak var lblSubTitle:UILabel?
    @IBOutlet weak var vContent:UIView?

    fileprivate var background:UIColor?
    fileprivate var selectedBackground:UIColor?
    fileprivate var cornerRadiusCell:CGFloat = 5

    fileprivate var isSelect:Bool = false;
    
    var item:MenuItem?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       //self.perform(#selector(setupUI), with: nil, afterDelay: 0.025)        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.perform(#selector(setupUI), with: nil, afterDelay: 0.025)
    }
   
    
    @objc func setupUI(){
        vContent?.layer.cornerRadius = cornerRadiusCell
        vContent?.clipsToBounds = true
    }
    
    func configura(item:MenuItem,
                   isSelect:Bool,
                   backgroundColor:UIColor = UIColor.white,
                   selectedBackgroundColor:UIColor = UIColor.blue, cornerRadius:CGFloat? = nil)  {
        self.isSelect = isSelect
        self.item = item
        self.background = backgroundColor
        if cornerRadius != nil {
            self.cornerRadiusCell = cornerRadius!
        }
        self.selectedBackground = selectedBackgroundColor
        updateUI()
    }
    
    func updateUI()  {
        lblTitle?.text = E(item?.name).localized
 
        if isSelect == true {
            lblTitle?.textColor = background
            vContent?.backgroundColor = selectedBackground
            
        }else {
            lblTitle?.textColor = selectedBackground
            vContent?.backgroundColor = background
        }
    }
}
