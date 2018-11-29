//
//  OrderDetailTableViewCell.swift
//  SRSDriver
//
//  Created by phunguyen on 3/16/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

protocol OrderDetailTableViewCellDelegate:class {
    func didSelectedDopdown(_ cell:OrderDetailTableViewCell,_ btn:UIButton)
}


struct OrderDetailInforRow {
    var title: String = ""
    var content: String = ""
    
    init(_ title:String , _ content:String) {
        self.title = title
        self.content = content
    }
}


class OrderDetailTableViewCell: UITableViewCell {
  
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var contentLabel: UILabel?
    @IBOutlet weak var iconImgView: UIImageView?
    @IBOutlet weak var lineView: UIView?
    @IBOutlet weak var vContent: UIView?


    weak var delegate:OrderDetailTableViewCellDelegate?
    var orderDetailItem: OrderDetailInforRow! {
        didSet {
            nameLabel?.text = orderDetailItem.title
            contentLabel?.text = orderDetailItem.content
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel?.numberOfLines = 0
    }
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func onbtnClickDropdown(btn:UIButton){
        delegate?.didSelectedDopdown(self, btn)
    }
}



