//
//  OrderDetailSKUCell.swift
//  DMSDriver
//
//  Created by Trung Vo on 9/25/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class OrderDetailSKUCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var loadedQtyLabel: UILabel!
    @IBOutlet weak var loadedQtyViewContainer: UIView!
    @IBOutlet weak var loadedQtyHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deliveredQtyTextField: UITextField!
    
    @IBOutlet weak var vContent: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(detail:Order.Detail) {
        nameLabel.text = detail.package?.name
        quantityLabel.text = IntSlash(detail.qty)
        if let loadedQty = detail.loadedQty {
            loadedQtyLabel.text = "\(loadedQty)"
            loadedQtyHeightConstraint.constant = 22.0
        } else {
            // remove loadedQty record
            loadedQtyHeightConstraint.constant = 0.0
        }
    }

}
