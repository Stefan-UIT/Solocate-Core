//
//  RentingOrderDetailTableViewCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 9/24/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

struct RentingOrderDetailInforRow {
    var title: String = ""
    var content: String = ""
    var isHighlight = false
    var textColor:UIColor?
    
    
    init(_ title:String , _ content:String, _ isHighlight:Bool = false, _ textColor:UIColor? = nil ) {
        self.title = title
        self.content = content
        self.isHighlight = isHighlight
        self.textColor = textColor
    }
}

class RentingOrderDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var contentLabel: UILabel?
    
    var rentingOrderDetailItem: RentingOrderDetailInforRow! {
        didSet {
            nameLabel?.text = rentingOrderDetailItem.title
            contentLabel?.text = rentingOrderDetailItem.content
//            contentLabel?.textColor = orderDetailItem.isHighlight ? AppColor.buttonColor : AppColor.black
            if let color = rentingOrderDetailItem.textColor {
                contentLabel?.textColor = color
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel?.numberOfLines = 0
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
