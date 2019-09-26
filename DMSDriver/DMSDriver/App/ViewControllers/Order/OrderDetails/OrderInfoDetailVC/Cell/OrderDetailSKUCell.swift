//
//  OrderDetailSKUCell.swift
//  DMSDriver
//
//  Created by Trung Vo on 9/25/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

protocol OrderDetailSKUCellDelegate:class {
    func didEnterDeliveredQuantityTextField(_ cell:OrderDetailSKUCell, value:String, detail:Order.Detail)
}

class OrderDetailSKUCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var loadedQtyLabel: UILabel!
    @IBOutlet weak var loadedQtyViewContainer: UIView!
    @IBOutlet weak var loadedQtyHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deliveredQtyTextField: UITextField!
    var detail:Order.Detail!
    @IBOutlet weak var vContent: UIView!
    
    weak var delegate:OrderDetailSKUCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(detail:Order.Detail) {
        self.detail = detail
        nameLabel.text = detail.package?.name
        quantityLabel.text = IntSlash(detail.qty)
        if let loadedQty = detail.loadedQty {
            loadedQtyLabel.text = "\(loadedQty)"
            loadedQtyHeightConstraint.constant = 22.0
        } else {
            // remove loadedQty record
            loadedQtyHeightConstraint.constant = 0.0
        }
    }

}

extension OrderDetailSKUCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            guard let actualTextField = deliveredQtyTextField else { return true }
            if textField == actualTextField {
                delegate?.didEnterDeliveredQuantityTextField(self, value: updatedText, detail: self.detail)
            }
        }
        return true
    }
}
