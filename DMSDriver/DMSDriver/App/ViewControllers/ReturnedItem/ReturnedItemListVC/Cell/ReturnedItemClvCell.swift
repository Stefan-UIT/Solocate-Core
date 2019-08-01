
//
//  TaskListClvCell.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 10/22/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit

class ReturnedItemListClvCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblSubtitle: UILabel?
    @IBOutlet weak var lblStartdate: UILabel?
    @IBOutlet weak var lblEnddate: UILabel?
    @IBOutlet weak var lblDeliveryDate: UILabel?
    @IBOutlet weak var lblDeliverynumber: UILabel?
    @IBOutlet weak var lblUrgency: UILabel?
    @IBOutlet weak var lblContent: UILabel?
    @IBOutlet weak var btnStatus: UIButton?
    @IBOutlet weak var btnNumber: UIButton?
    @IBOutlet weak var vContent: UIView?
    
    var item:ReturnedItem?{
        didSet{
           updateUI()
        }
    }
    
    func updateUI()  {
        let displayDateTimeVN = DateFormatter.displayDateTimeVN
        let displayDateVN = DateFormatter.displayDateVietNames
        let startTime = DateFormatter.serverDateFormater.date(from: E(item?.dlvy_start_time))
        let endTime = DateFormatter.serverDateFormater.date(from: E(item?.dlvy_end_time))
        let deliveryDate = DateFormatter.displayDateUS.date(from: E(item?.dlvy_date))
        let status = TaskStatus(rawValue: E(item?.status.code)) ?? TaskStatus.open

        lblTitle?.text = "\("\("Item".localized) - \(item?.id ?? 0)")"
        lblSubtitle?.text = Slash(item?.instructions)
//        if Locale.current.languageCode == "he" {
//            lblUrgency?.text = item?.urgent_type_name_hb
//        }else {
//            lblUrgency?.text = item?.urgent_type_name_en
//        }
//        lblUrgency?.text = E(item?.urgency.name).localized
//        lblUrgency?.textColor = item?.colorUrgent
        btnStatus?.setTitle("\(status.statusName.localized)", for: .normal)
        btnStatus?.borderWidth = 1.0;
        btnStatus?.layer.cornerRadius = 3.0;
        btnStatus?.borderColor = item?.colorStatus;
        btnStatus?.setTitleColor(item?.colorStatus, for: .normal)
        lblStartdate?.text = (startTime != nil) ? displayDateTimeVN.string(from: startTime!) : ""
        lblEnddate?.text = (endTime != nil) ? displayDateTimeVN.string(from: endTime!) : ""
        lblDeliveryDate?.text  = (deliveryDate != nil) ? displayDateVN.string(from: deliveryDate!) : ""
        vContent?.cornerRadius = 4.0;
        vContent?.backgroundColor = AppColor.grayColor
    }
}
