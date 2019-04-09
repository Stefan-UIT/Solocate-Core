//
//  PickerTimeCell.swift
//  DMSDriver
//
//  Created by Mach Van  Nguyen on 4/5/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

protocol PickerTimeCellDelegate:AnyObject {
    func pickerTimeCell(pickerTimeCell:PickerTimeCell,changeValue date:Date)
}


class PickerTimeCell: UITableViewCell {
    
    @IBOutlet weak var datePicker:UIDatePicker?
    
    weak var delegate:PickerTimeCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.datePicker?.timeZone = TimeZone.current
        self.datePicker?.minuteInterval = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    @IBAction func pickerDidchangeValue(datePicker:UIDatePicker) {
        print("Did change: \(datePicker.date)")
        delegate?.pickerTimeCell(pickerTimeCell: self, changeValue: datePicker.date)
    }
}
