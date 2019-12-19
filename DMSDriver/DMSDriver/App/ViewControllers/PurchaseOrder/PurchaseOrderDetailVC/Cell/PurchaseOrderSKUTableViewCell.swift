//
//  PurchaseOrderSKUTableViewCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 12/17/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class PurchaseOrderSKUTableViewCell: UITableViewCell {
    @IBOutlet weak var skuLbl: UILabel!
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var uomLbl: UILabel!
    @IBOutlet weak var batchIdLbl: UILabel!
    @IBOutlet weak var barcodeLbl: UILabel!
    @IBOutlet weak var deliveringQtyLbl: UILabel!
    @IBOutlet weak var deliveredQtyLbl: UILabel!
    @IBOutlet weak var remainingQtyLbl: UILabel!
    
    var purchaseOrderSKU:PurchaseOrder.Detail?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(purchaseOrderSKU: PurchaseOrder.Detail) {
        skuLbl.text = Slash(purchaseOrderSKU.name)
        quantityLbl.text = IntSlash(purchaseOrderSKU.pivot?.qty)
        uomLbl.text = Slash(purchaseOrderSKU.pivot?.uom?.name)
        batchIdLbl.text = Slash(purchaseOrderSKU.pivot?.batch_id)
        barcodeLbl.text = Slash(purchaseOrderSKU.pivot?.bcd)
        deliveringQtyLbl.text = IntSlash(purchaseOrderSKU.pivot?.deliveringQty)
        deliveredQtyLbl.text = IntSlash(purchaseOrderSKU.pivot?.deliveredQty)
        remainingQtyLbl.text = IntSlash(purchaseOrderSKU.pivot?.remainingQty)
    }

}
