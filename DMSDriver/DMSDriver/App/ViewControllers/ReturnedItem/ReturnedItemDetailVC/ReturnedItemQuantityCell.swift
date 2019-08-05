//
//  ReturnedItemQuantityCell.swift
//  DMSDriver
//
//  Created by Trung Vo on 7/31/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

class ReturnedItemQuantityCell: UITableViewCell {
    
    @IBOutlet weak var packageNameLabel: UILabel?
    @IBOutlet weak var quantityLabel: UILabel?
    @IBOutlet weak var lblBarcode: UILabel?
    @IBOutlet weak var wmsOrderCodeLabel: UILabel?
    @IBOutlet weak var iconImgView: UIImageView?
    @IBOutlet weak var lineView: UIView?
    @IBOutlet weak var vContent: UIView?
    
    @IBOutlet weak var actualQuantityTextField: UITextField?
    @IBOutlet weak var actualCartonsInPalletTextField: UITextField?
    
    @IBOutlet weak var cartonInPalletsLabel: UILabel?
    @IBOutlet weak var cartonInPalletViewContainer: UIView?
    
    
    @IBOutlet weak var cartonsViewContainerHeightConstraint: NSLayoutConstraint?
    
    
    @IBOutlet weak var quantityViewContainerHeightConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var cartonsViewContainerTopSpacing: NSLayoutConstraint?
    
    
    @IBOutlet weak var deliveredQtyStaticLabel: UILabel?
    @IBOutlet weak var deliveredCartonsStaticLabel: UILabel?
    var item:ReturnedItem!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        guard let palletTextField = actualQuantityTextField else { return }
        palletTextField.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCellWithDetail(_ item:ReturnedItem) {
        self.item = item
        quantityLabel?.text = "\(item.totalQuantity ?? 0)"
        actualQuantityTextField?.text = (item.returnedQuantity != nil) ? "\(item.returnedQuantity!)" : ""
        
        vContent?.cornerRadius = 0
        handleShowingActualQuantityTextField(isHidden: !item.isAllowedToUpdateReturnedItemTextField)
    }
    
    func handleShowingActualQuantityTextField(isHidden:Bool) {
        quantityViewContainerHeightConstraint?.constant = (isHidden) ? 22.0 : 45.0
        actualQuantityTextField?.isHidden = isHidden
        deliveredQtyStaticLabel?.isHidden = isHidden
    }
    
}

//MARK: - UITEXTFIELD
extension ReturnedItemQuantityCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let palletTextField = actualQuantityTextField else { return }
        let text =  textField.text ?? ""
        if textField == palletTextField {
            item.returnedQuantity = Int(text)
            //            delegate?.didEnterPalletsQuantityTextField(self, value: text, detail: self.detail)
        }
    }
}
