//
//  ProfileCell.swift
//  DMSDriver
//
//  Created by phunguyen on 7/4/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

protocol ProfileCellDelegate {
  func didSelctEdit(cell:ProfileCell, btn:UIButton)
  func didSelctChagePassword(cell:ProfileCell, btn:UIButton)

}

class ProfileCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel?
    @IBOutlet weak var tfContent:UITextField?
    @IBOutlet weak var imvAvartar:UIImageView?
    @IBOutlet weak var btnEdit:UIButton?
    @IBOutlet weak var lineEdit:UIView?

  
    var delegate:ProfileCellDelegate?
  
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
    @IBAction func onbtnClickEdit(btn:UIButton){
      delegate?.didSelctEdit(cell: self, btn: btn)
    }
  
    @IBAction func onbtnClickChagePassword(btn:UIButton){
      delegate?.didSelctChagePassword(cell: self, btn: btn)
    }
}
