//
//  LoadMoreView.swift
//
//  Created by machnguyen_uit on 11/22/18.
//  Copyright © 2018 horical. All rights reserved.
//

import UIKit

class LoadMoreView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    class func loadingMoreView() -> UIView {
        let lblLoadMore = UILabel()
        lblLoadMore.textAlignment = .center
        lblLoadMore.setStyleCircleWhiteTextBlueBackground()
        lblLoadMore.text = "Loading more..."
        
        return lblLoadMore
    }

    class func loadingMoreCell() -> UITableViewCell {
        let cell = UITableViewCell()

        let lbl = loadingMoreView()
        lbl.frame = CGRectMake(0, 0, ScreenSize.SCREEN_WIDTH, 24)
        
        cell.addSubview(lbl)
        return cell
    }
}
