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
    @IBOutlet weak var truckLbl: UILabel!
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
        self.rentingOrder = rentingOrder
        orderIdLbl.text = "#"+"\(rentingOrder.rentingOrderId ?? 0)"
        statusLbl.text = rentingOrder.rentingStatus?.statusName.localized
        statusLbl.textColor = rentingOrder.rentingStatus?.color
        startDateLbl.text = rentingOrder.startDate ?? ""
        endDateLbl.text = rentingOrder.endDate ?? ""
        dateLbl.text = rentingOrder.endDate ?? ""
        refCodeLbl.text = "\(rentingOrder.refCode ?? 0)"
        customerLbl.text = rentingOrder.customerName ?? ""
        truckLbl.text = rentingOrder.truckType?.name ?? ""
    }
    
}
