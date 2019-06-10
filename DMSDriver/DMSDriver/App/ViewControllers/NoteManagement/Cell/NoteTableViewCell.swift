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
    @IBOutlet weak var attachedFilesLabel: UILabel!
    @IBOutlet weak var attachedFilesButton: Button!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        statusButton.borderWidth = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func shouldHideAttachedFilesSection(isHidden:Bool) {
        self.attachedFilesLabel.isHidden = isHidden
        self.attachedFilesButton.isHidden = isHidden
    }
    
    func configureCell(note:Note) {
        
        self.authorNameLabel.text = note.user.userName ?? ""
        self.contentLabel.text = note.content
        self.timeLabel.text = note.createdAt
        let numberOfAttachedFiles = note.files.count
        shouldHideAttachedFilesSection(isHidden: numberOfAttachedFiles==0)
        if numberOfAttachedFiles > 0 {
            self.attachedFilesLabel.text = (numberOfAttachedFiles > 1) ? "\(numberOfAttachedFiles) attached files" : "\(numberOfAttachedFiles) attached file"
        }
        
        
        let statusOrder = StatusOrder(rawValue: note.status.code ?? "OP")
        statusButton.borderColor = statusOrder?.color
        statusButton.setTitle(statusOrder?.statusName, for: .normal)
        statusButton.setTitleColor(statusOrder?.color, for: .normal)
    }

}
