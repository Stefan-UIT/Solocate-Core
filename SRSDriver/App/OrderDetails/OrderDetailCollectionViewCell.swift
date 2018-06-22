//
//  OrderDetailCollectionViewCell.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class OrderDetailCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var iconImgView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  
  
  var orderDetail: OrderDetail?
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
}
