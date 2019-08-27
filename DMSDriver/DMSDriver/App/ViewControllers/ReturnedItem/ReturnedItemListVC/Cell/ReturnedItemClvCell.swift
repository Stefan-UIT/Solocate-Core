
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
    @IBOutlet weak var lblRouteName: UILabel!
    @IBOutlet weak var lblRouteDate: UILabel!
    @IBOutlet weak var lblWareHouse: UILabel!
    @IBOutlet weak var lblDriver: UILabel!
    
    var item:ReturnedItem?{
        didSet{
           updateUI()
        }
    }
    
    func updateUI()  {
        let displayTime = DateFormatter.hour24Formater
        let displayDate = DateFormatter.displayDateVietNames
        let startTime = DateFormatter.serverDateFormater.date(from: E(item?.dlvy_start_time))
        let endTime = DateFormatter.serverDateFormater.date(from: E(item?.dlvy_end_time))
        let deliveryDate = DateFormatter.displayDateUS.date(from: E(item?.dlvy_date))
        let status = TaskStatus(rawValue: E(item?.status.code)) ?? TaskStatus.open

        lblTitle?.text = "\("\("item".localized) - \(item?.id ?? 0)")"
        
        lblRouteName?.text = item?.route_name
        lblRouteDate?.text = endTime != nil ? Slash(displayDate.string(from: endTime!)) : "-"
        lblWareHouse?.text = item?.warehouse?.name != nil ? item?.warehouse?.name : item?.warehouse?.address
        lblDriver?.text = "driver"
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
        lblStartdate?.text = startTime != nil ? Slash(displayTime.string(from: startTime!)) : "-"
        lblEnddate?.text = endTime != nil ? Slash(displayTime.string(from: endTime!)) : "-"
        lblDeliveryDate?.text  = deliveryDate != nil ? Slash(displayTime.string(from: deliveryDate!)) : "-"
        vContent?.cornerRadius = 4.0;
        vContent?.backgroundColor = AppColor.grayColor
    }
}
