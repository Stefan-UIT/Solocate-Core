//
//  HistoryNotifyDetailCell.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 12/19/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit

struct NotifylInforRow {
    var title: String = ""
    var content: String = ""
    var isHighlight = false
    
    
    init(_ title:String , _ content:String, _ isHighlight:Bool = false) {
        self.title = title
        self.content = content
        self.isHighlight = isHighlight
    }
}

class HistoryNotifyDetailCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel:UILabel?
    @IBOutlet weak var contentLabel:UILabel?
    @IBOutlet weak var vContent:UIView?


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var infoRow: NotifylInforRow! {
        didSet {
            nameLabel?.text = infoRow.title
            contentLabel?.text = infoRow.content
            contentLabel?.textColor = infoRow.isHighlight ? AppColor.mainColor : AppColor.black
        }
    }
}
