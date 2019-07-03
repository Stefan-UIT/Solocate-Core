
//
//  TaskListClvCell.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 10/22/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit

class TaskListClvCell: UICollectionViewCell {
    
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
    
    var task:TaskModel?{
        didSet{
           updateUI()
        }
    }
    
    func updateUI()  {
        let displayDateTimeVN = DateFormatter.displayDateTimeVN
        let displayDateVN = DateFormatter.displayDateVietNames
        let startTime = DateFormatter.serverDateFormater.date(from: E(task?.dlvy_start_time))
        let endTime = DateFormatter.serverDateFormater.date(from: E(task?.dlvy_end_time))
        let deliveryDate = DateFormatter.displayDateUS.date(from: E(task?.dlvy_date))
        let status = TaskStatus(rawValue: E(task?.status.code)) ?? TaskStatus.open

        lblTitle?.text = "\("\("TASK".localized) - \(task?.id ?? 0)")"
        lblSubtitle?.text = task?.instructions
//        if Locale.current.languageCode == "he" {
//            lblUrgency?.text = task?.urgent_type_name_hb
//        }else {
//            lblUrgency?.text = task?.urgent_type_name_en
//        }
        lblUrgency?.text = E(task?.urgency.name).localized
        lblUrgency?.textColor = task?.colorUrgent
        btnStatus?.setTitle("\(status.statusName)", for: .normal)
        btnStatus?.borderWidth = 1.0;
        btnStatus?.layer.cornerRadius = 3.0;
        btnStatus?.borderColor = task?.colorStatus;
        btnStatus?.setTitleColor(task?.colorStatus, for: .normal)
        lblStartdate?.text = (startTime != nil) ? displayDateTimeVN.string(from: startTime!) : ""
        lblEnddate?.text = (endTime != nil) ? displayDateTimeVN.string(from: endTime!) : ""
        lblDeliveryDate?.text  = (deliveryDate != nil) ? displayDateVN.string(from: deliveryDate!) : ""
        vContent?.cornerRadius = 4.0;
        vContent?.backgroundColor = AppColor.grayColor
    }
}
