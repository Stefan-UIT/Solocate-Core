//
//  BaseScrollMenuView.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 10/31/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit

protocol BaseScrollMenuViewDelegate:class {
    func baseScrollMenuViewDidSelectAtIndexPath(_ view:BaseScrollMenuView ,_ indexPath:IndexPath)
}


class BaseScrollMenuView: UIView {
    
    var scrollMenu:ScrollMenuView?
    var delegate:BaseScrollMenuViewDelegate?
    var backgroundCell:UIColor = UIColor.white
    var selectedBackground:UIColor  = UIColor.blue
    var cornerRadiusCell:CGFloat?

    
    var indexSelect:Int = 0 {
        didSet{
            scrollMenu?.indexSelect = indexSelect
            scrollMenu?.clvContent?.reloadData()
        }
    }

    var dataSource:[MenuItem]?{
        didSet{
            scrollMenu?.backgroundCell = backgroundCell
            scrollMenu?.selectedBackground = selectedBackground
            scrollMenu?.indexSelect = indexSelect
            scrollMenu?.listItems = dataSource
            scrollMenu?.clvContent?.reloadData()
        }
    }



    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        setupScrollMenuView()
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        //setupScrollMenuView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupScrollMenuView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //setupScrollMenuView()
    }
    
    
    func setupScrollMenuView() {
        if scrollMenu == nil {
            scrollMenu = ScrollMenuView.load(nib: "ScrollMenuView", owner: nil)
            scrollMenu?.backgroundCell = backgroundCell
            scrollMenu?.selectedBackground = selectedBackground
            scrollMenu?.cornerRadiusCell = cornerRadiusCell
            scrollMenu?.delegate = self
            self.addSubview(scrollMenu!)
            scrollMenu?.addConstaints(top: 0, right: 0, bottom: 0, left: 0)
            self.layoutIfNeeded()
            self.updateConstraintsIfNeeded()
        }
    }
}


//MARK: - ScrollMenuViewDelagate
extension BaseScrollMenuView: ScrollMenuViewDelagate{
    func didSelectItemMenu(view: ScrollMenuView, indexPath: IndexPath) {
        delegate?.baseScrollMenuViewDidSelectAtIndexPath(self, indexPath)
    }
}
