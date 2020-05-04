//
//  BusinessOrderTableViewCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/19/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import UIKit

class BusinessOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var routeIdLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var orderTypeLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!
    
    var purchaseOrder:BusinessOrder!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureCell(_ businessOrder:BusinessOrder) {
        var startTime = "NA".localized
        var endTime = "NA".localized
        var startDate = "NA".localized
        var endDate = "NA".localized
        if let start = businessOrder.dueDateFrom?.date {
            startTime = Hour24Formater.string(from:start)
            startDate = ShortDateFormater.string(from:start)
        }
        if let end = businessOrder.dueDateTo?.date {
            endTime = Hour24Formater.string(from:end)
            endDate = ShortDateFormater.string(from:end)
        }
        //        self.rentingOrder = rentingOrder
        routeIdLabel.text = "#" + Slash(businessOrder.companySeqID)
        statusLabel.text = businessOrder.status?.name?.localized
        statusLabel.textColor = businessOrder.colorStatus
        timeLabel.text = startTime + " - " + endTime
        dueDateLabel.text = startDate + " - " + endDate
        
        orderTypeLabel.text = Slash(businessOrder.orderType.name)
        customerNameLabel.text = Slash(businessOrder.customer?.userName)
        remarkLabel.text = Slash(businessOrder.remark)
        itemsLabel.text = IntSlash(businessOrder.details?.count)
    }

}
