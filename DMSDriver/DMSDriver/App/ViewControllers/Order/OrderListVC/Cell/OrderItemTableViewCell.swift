//
//  OrderItemTableViewCell.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class OrderItemTableViewCell: UITableViewCell {
  
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblSubtitle: UILabel?
    @IBOutlet weak var lblFromAddresss: UILabel?
    @IBOutlet weak var lblToAddress: UILabel?
    @IBOutlet weak var lblNatureOfGoods: UILabel?
    @IBOutlet weak var lblUrgency: UILabel?

    @IBOutlet weak var lblCustomerName: UILabel!
    @IBOutlet weak var lblConsigneeName: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
//    @IBOutlet weak var lblPallet: UILabel!
    @IBOutlet weak var orderTypeLabel: UILabel?
    
    @IBOutlet weak var lblExpectedTime: UILabel?
    @IBOutlet weak var lblRecordsFrom: UILabel?
    @IBOutlet weak var btnStatus: UIButton?
    @IBOutlet weak var btnPropety: UIButton?
    @IBOutlet weak var lblNumber: UILabel?
    @IBOutlet weak var lblDate: UILabel?
    @IBOutlet weak var vContent: UIView?

    
//    @IBOutlet weak var lblCartonInPallets: UILabel!
//    @IBOutlet weak var lblPalletHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var lblPalletTopConstraint: NSLayoutConstraint!
    
    var order: Order! {
        didSet {
            updateCell()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCell() {
        guard let detail = order.details?.first else { return }
        
        var startDate = "NA".localized
        var endDate = "NA".localized
        var dateDate = "NA".localized
        if let start = order.from?.start_time?.date {
            startDate = HourFormater.string(from:start)
        }
        if let end = order.to?.end_time?.date {
            endDate = HourFormater.string(from:end)
            dateDate = DateFormatter.shortDate.string(from:end)
        }
        
//        lblNumber?.text = "\(order.seq)."
        lblTitle?.text = String(format: "#%d".localized, order.id)
        lblCustomerName?.text = order.customer?.userName
        lblConsigneeName?.text = order.consigneeName
        lblQuantity?.text = "\(detail.qty ?? 0)"
//        if detail.isPallet {
//            lblPallet?.text = "\(detail.cartonsInPallet ?? 0)"
//        } else {
//            lblPallet.isHidden = true
//            lblCartonInPallets.isHidden = true
//            lblPalletHeightConstraint.constant = 0
//            lblPalletTopConstraint.constant = 0
//        }
        orderTypeLabel?.text = order.orderType.name
        lblFromAddresss?.text = order.from?.address
        lblToAddress?.text = order.to?.address
        lblUrgency?.textColor = order.colorUrgent
        lblExpectedTime?.text = "\(startDate) - \(endDate)"
        lblDate?.text = dateDate.uppercased()

        if Locale.current.languageCode == "he" {
            lblUrgency?.text = order.urgent_type_name_hb
            lblSubtitle?.text = order.order_type_name_hb

        }else {
            lblUrgency?.text = order.urgent_type_name_en
            lblSubtitle?.text = order.order_type_name
        }
        
        let status = StatusOrder(rawValue: E(order.status?.code)) ?? StatusOrder.newStatus
        btnStatus?.setTitle(status.statusName.localized, for: .normal)
        btnStatus?.setTitleColor(order.colorStatus, for: .normal)
        btnStatus?.borderWidth = 1.0;
        btnStatus?.layer.cornerRadius = 3.0;
        btnStatus?.borderColor = order.colorStatus;
        vContent?.cornerRadius = 10;
    }
}
