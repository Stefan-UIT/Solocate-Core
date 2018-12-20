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
        lbl.addConstaints(top: 0, right: 0, bottom: 0, left: 0)        
        cell.addSubview(lbl)
        return cell
    }
}
