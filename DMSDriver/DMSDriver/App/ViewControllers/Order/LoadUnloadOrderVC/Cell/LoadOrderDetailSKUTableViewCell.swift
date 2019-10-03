//
//  LoadOrderDetailSKUTableViewCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 9/26/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

protocol LoadOrderDetailSKUTableViewCellDelete:class {
    func didEnterDeliveredQuantityTextField(_ cell:LoadOrderDetailSKUTableViewCell, value:String, detail:Order.Detail)
}

class LoadOrderDetailSKUTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var barCodeLabel: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var loadedQtyLabel: UILabel!
    @IBOutlet weak var loadedQtyViewContainer: UIView!
    @IBOutlet weak var loadedQtyHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deliveredQtyTextField: UITextField!
    @IBOutlet weak var vContent: UIView!
    
    weak var delegate:LoadOrderDetailSKUTableViewCellDelete?
    var detail:Order.Detail!
    var updatedText:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(detail:Order.Detail, order:Order) {
        deliveredQtyTextField.delegate = self
        self.detail = detail
        nameLabel.text = detail.package?.name
        barCodeLabel.text = detail.barCode ?? "-"
        orderIdLabel.text = "\(detail.order_id ?? 0)"
        customerNameLabel.text = order.customer_name
        quantityLabel.text = IntSlash(detail.pivot?.qty)
        loadedQtyHeightConstraint.constant = 0.0
    }

    @IBAction func onLoadButtonTouchUp(_ sender: Any) {
        guard let updatedText = deliveredQtyTextField.text else { return }
        delegate?.didEnterDeliveredQuantityTextField(self, value: updatedText, detail: self.detail)
    }
    
}

extension LoadOrderDetailSKUTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            guard let actualTextField = deliveredQtyTextField else { return true }
            if textField == actualTextField {
                detail.pivot?.loadedQty = Int(updatedText)
            }
        }
        return true
    }
}


