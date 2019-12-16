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
    @IBOutlet weak var startDateLbl: UILabel!
    @IBOutlet weak var endDateLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var divisionLbl: UILabel!
    @IBOutlet weak var refCodeLbl: UILabel!
    @IBOutlet weak var customerNameLbl: UILabel!
    @IBOutlet weak var zoneLbl: UILabel!
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
        var startDate = "NA".localized
        var endDate = "NA".localized
        if let start = rentingOrder.startDate?.date {
            startDate = HourFormater.string(from:start)
        }
        if let end = rentingOrder.endDate?.date {
            endDate = HourFormater.string(from:end)
        }
        self.rentingOrder = rentingOrder
        orderIdLbl.text = "#"+"\(rentingOrder.id)"
        statusLbl.text = rentingOrder.rentingOrderStatus?.name?.localized
        statusLbl.textColor = rentingOrder.rentingOrderStatusColor
        startDateLbl.text = startDate + " - "
        endDateLbl.text = endDate
        dateLbl.text = endDate
        
        refCodeLbl.text = "\(rentingOrder.referenceCode)"
        customerNameLbl.text = rentingOrder.rentingOrderCustomer?.userName ?? ""
        detailsLbl.text = "\(rentingOrder.rentingOrderDetails?.count ?? 0)"
        zoneLbl.text = "zone"
        divisionLbl.text = "division"
    }
}
