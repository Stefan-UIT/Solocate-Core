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
    var dataSource:[MenuItem]?
    var indexSelectDefault:Int = 0
    
    var indexSelect:Int = 0 {
        didSet{
            scrollMenu?.indexSelect = indexSelect
            scrollMenu?.clvContent?.reloadData()
        }
    }
    
    func reloadData(){
        scrollMenu?.backgroundCell = backgroundCell
        scrollMenu?.selectedBackground = selectedBackground
        scrollMenu?.cornerRadiusCell = cornerRadiusCell
        scrollMenu?.indexSelect = indexSelectDefault
        scrollMenu?.listItems = dataSource
        scrollMenu?.clvContent?.reloadData()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.perform(#selector(setupScrollMenuView), on: Thread.main, with: nil, waitUntilDone: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.perform(#selector(setupScrollMenuView), on: Thread.main, with: nil, waitUntilDone: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.perform(#selector(setupScrollMenuView), on: Thread.main, with: nil, waitUntilDone: true)
    }
    
    
    @objc func setupScrollMenuView() {
        if scrollMenu == nil {
            scrollMenu = ScrollMenuView.load(nib: "ScrollMenuView", owner: nil)
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
