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
    
    @IBOutlet weak var deliveredQtyStaticLabel: UILabel!
    
    @IBOutlet weak var deliveredQtyHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var deliveredQtyViewContainer: UIView!
    weak var delegate:OrderDetailSKUCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        deliveredQtyTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(detail:Order.Detail, order:Order) {
        self.detail = detail
        nameLabel.text = detail.package?.name
        quantityLabel.text = IntSlash(detail.qty)
        
        updateDeliverdQtyUI(order: order)
        updateLoadedQtyUI()
        handleDisablingTextField(order:order)
        updateDeliveredTextFieldValue(order: order)
    }
    
    func updateDeliveredTextFieldValue(order:Order) {
        let isPickUpAndNewOrder = order.isPickUpType && order.isNewStatus
        var actualQty:String!
        if order.isCancelled {
            actualQty = "0"
        } else {
            actualQty = (isPickUpAndNewOrder) ? "\(detail.loadedQty ?? 0)" : "\(detail.actualQty ?? 0)"
        }
        deliveredQtyTextField.text = actualQty
    }
    
    func handleDisablingTextField(order:Order) {
        var isDisabled:Bool!
        if order.isPickUpType {
            isDisabled = order.isCancelled || order.isFinished
        } else {
            isDisabled = !order.isInTransit
        }
        deliveredQtyTextField.isEnabled = !isDisabled
    }
    
    func updateDeliverdQtyUI(order:Order) {
        if order.isPickUpType {
            deliveredQtyStaticLabel?.text = (order.isNewStatus) ? "picked-up-quantity".localized : "delivered-quantity".localized
        } else {
            let isHidden = order.isNewStatus || order.isLoaded
            deliveryQtyViewContainer(isHidden: isHidden)
        }
    }
    
    func deliveryQtyViewContainer(isHidden:Bool) {
        deliveredQtyHeightConstraint.constant = isHidden ? 0.0 : 25.0
        deliveredQtyViewContainer.isHidden = isHidden
    }
    
    func loadedQtyViewContainer(isHidden:Bool) {
        loadedQtyHeightConstraint.constant = isHidden ? 0.0 : 22.0
        loadedQtyViewContainer.isHidden = isHidden
    }
    
    func updateLoadedQtyUI() {
        if let loadedQty = detail.loadedQty {
            loadedQtyLabel.text = "\(loadedQty)"
            loadedQtyViewContainer(isHidden:false)
        } else {
            // remove loadedQty record
            loadedQtyViewContainer(isHidden:true)
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
