//
//  NoteTableViewCell.swift
//  DMSDriver
//
//  Created by Trung Vo on 6/6/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        statusButton.borderWidth = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(note:Note) {
        
        self.authorNameLabel.text = note.updatedBy
        self.contentLabel.text = note.content
        self.timeLabel.text = note.createdAt
        
//        statusButton.borderColor = orderDetail?.colorStatus
        statusButton.setTitle(note.statusName, for: .normal)
//        statusButton.setTitleColor(orderDetail?.colorStatus, for: .normal)
    }

}
