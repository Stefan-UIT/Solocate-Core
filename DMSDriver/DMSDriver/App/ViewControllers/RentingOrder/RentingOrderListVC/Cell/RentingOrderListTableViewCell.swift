//
//  RentingOrderListTableViewCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 9/24/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class RentingOrderListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var orderIdLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var startDateLbl: UILabel!
    @IBOutlet weak var endDateLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var refCodeLbl: UILabel!
    @IBOutlet weak var customerLbl: UILabel!
    @IBOutlet weak var detailsLbl: UILabel!
    var rentingOrder:RentingOrder!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCellWithRentingOrder(_ rentingOrder:RentingOrder) {
        var startTime = "NA".localized
        var endTime = "NA".localized
        var dueDate = "NA".localized
        if let start = rentingOrder.startDate?.date {
            startTime = HourFormater.string(from:start)
        }
        if let end = rentingOrder.endDate?.date {
            endTime = HourFormater.string(from:end)
            dueDate = ShortDateFormater.string(from: end)
        }
        self.rentingOrder = rentingOrder
        orderIdLbl.text = "#"+"\(rentingOrder.id)"
        statusLbl.text = rentingOrder.rentingOrderStatus?.name?.localized
        statusLbl.textColor = rentingOrder.rentingOrderStatusColor
        startDateLbl.text = startTime + " - "
        endDateLbl.text = endTime
        dateLbl.text = dueDate
        refCodeLbl.text = "\(rentingOrder.referenceCode)"
        customerLbl.text = rentingOrder.rentingOrderCustomer?.userName ?? ""
        detailsLbl.text = "\(rentingOrder.rentingOrderDetails?.count ?? 0)"
    }
}
