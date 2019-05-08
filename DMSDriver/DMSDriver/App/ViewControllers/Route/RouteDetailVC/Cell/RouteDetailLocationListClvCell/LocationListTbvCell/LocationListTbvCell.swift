//
//  LocationListTbvCell.swift
//  DMSDriver
//
//  Created by Seldat on 5/8/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class LocationListTbvCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblSubtitle: UILabel?
    @IBOutlet weak var lblFromAddresss: UILabel?
    @IBOutlet weak var lblToAddress: UILabel?
    @IBOutlet weak var lblLocationName: UILabel?
    @IBOutlet weak var lblExpectedTime: UILabel?
    @IBOutlet weak var lblRecordsFrom: UILabel?
    @IBOutlet weak var btnStatus: UIButton?
    @IBOutlet weak var btnPropety: UIButton?
    @IBOutlet weak var lblNumber: UILabel?
    @IBOutlet weak var lblDate: UILabel?
    @IBOutlet weak var vContent: UIView?
    
    var address: Address! {
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
        var startDate = ""
        if let date = address?.start_time?.date {
            startDate =  DateFormatter.displayDateTimeVN.string(from:date)
        }
        
        var endDate = ""
        if let date = address?.end_time?.date {
            endDate =  DateFormatter.displayDateTimeVN.string(from:date)
        }
        
        selectionStyle = .none
        lblTitle?.text = address?.address
        lblSubtitle?.text = "\(address?.ctt_name ?? "") | \(address?.ctt_phone ?? "")"
        lblNumber?.text = "\(address?.seq ?? 1)"
        lblExpectedTime?.text = "\(startDate) - \(endDate)"
        lblLocationName?.text = "Location name: \(address.loc_name ?? "")"
    }
}
