//
//  NoteTableViewCell.swift
//  SRSDriver
//
//  Created by phunguyen on 3/16/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
  
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var createdAtLabel: UILabel!
  @IBOutlet weak var authorLabel: UILabel!
  var note: Note! {
    didSet {
      authorLabel.text = note.author
      createdAtLabel.text = note.createdAt
      contentLabel.text = note.content
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
