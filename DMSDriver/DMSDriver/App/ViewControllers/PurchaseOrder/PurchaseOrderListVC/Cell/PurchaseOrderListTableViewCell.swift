//
//  PurchaseOrderListTableViewCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 12/16/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class PurchaseOrderListTableViewCell: UITableViewCell {

    @IBOutlet weak var orderIdLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var rangeDateLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var divisionLbl: UILabel!
    @IBOutlet weak var refCodeLbl: UILabel!
    @IBOutlet weak var customerNameLbl: UILabel!
    @IBOutlet weak var zoneLbl: UILabel!
    @IBOutlet weak var detailsLbl: UILabel!
    var purchaseOrder:PurchaseOrder!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(_ purchaseOrder:PurchaseOrder) {
        var startTime = "NA".localized
        var endTime = "NA".localized
        var startDate = "NA".localized
        var endDate = "NA".localized
        if let start = purchaseOrder.dueDateFrom?.date {
            startTime = Hour24Formater.string(from:start)
            startDate = ShortDateFormater.string(from:start)
        }
        if let end = purchaseOrder.dueDateTo?.date {
            endTime = Hour24Formater.string(from:end)
            endDate = ShortDateFormater.string(from:end)
        }
//        self.rentingOrder = rentingOrder
        orderIdLbl.text = "#"+"\(purchaseOrder.id)"
        statusLbl.text = purchaseOrder.status?.name?.localized
        statusLbl.textColor = purchaseOrder.colorStatus
        rangeDateLbl.text = startTime + " - " + endTime
        dateLbl.text = startDate + " - " + endDate
        
        refCodeLbl.text = Slash(purchaseOrder.referenceCode)
        customerNameLbl.text = Slash(purchaseOrder.customer?.userName)
        detailsLbl.text = IntSlash(purchaseOrder.details?.count)
        zoneLbl.text = Slash(purchaseOrder.zone?.name)
        divisionLbl.text = Slash(purchaseOrder.division?.name)
    }
}
