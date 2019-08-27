//
//  PackageTableViewswift
//  DMSDriver
//
//  Created by Trung Vo on 7/25/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

protocol LoadPackageTableViewCellDelegate:class {
    func didTouchOnLoadButton(_ cell:LoadPackageTableViewCell, detail:Order.Detail)
//    func didEnterPalletsQuantityTextField(_ cell:LoadPackageTableViewCell, value:String, detail:Order.Detail)
//    func didEnterCartonsQuantityTextField(_ cell:LoadPackageTableViewCell, value:String, detail:Order.Detail)
}

class LoadPackageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var consigneeNameLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
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
    
    
    @IBOutlet weak var palletsViewContainerHeightConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var cartonsViewContainerTopSpacing: NSLayoutConstraint?
    
    
    @IBOutlet weak var deliveredQtyStaticLabel: UILabel?
    @IBOutlet weak var deliveredCartonsStaticLabel: UILabel?
    
    
    @IBOutlet weak var orderIDLabel: UILabel?
    
    
    weak var delegate:LoadPackageTableViewCellDelegate?
    var detail:Order.Detail!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        guard let palletTextField = actualQuantityTextField, let cartonTextField = actualCartonsInPalletTextField else { return }
        palletTextField.delegate = self
        cartonTextField.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func handleShowingCartonSection() {
        let isShowedCartonSection = detail.package?.cd == PackageE.Pallet.rawValue
        cartonInPalletViewContainer?.isHidden = !isShowedCartonSection
        
        if isShowedCartonSection {
            cartonsViewContainerHeightConstraint?.constant = 50.0
            cartonsViewContainerTopSpacing?.constant = 6.0
            cartonInPalletsLabel?.text = "\(detail.cartonsInPallet ?? 0)"
            actualCartonsInPalletTextField?.text = (detail.loadedCartonsInPallet != nil) ? "\(detail.loadedCartonsInPallet!)" : ""            
        } else {
            cartonsViewContainerHeightConstraint?.constant = 0.0
            cartonsViewContainerTopSpacing?.constant = 0.0
        }
    }
    
    func configureCellWithOrder(_ order:Order) {
        guard let detail = order.details?.first else { return }
        self.detail = detail
        orderIDLabel?.text = (detail.order_id != nil) ? "\(detail.order_id!)" : "-"
        packageNameLabel?.text = detail.package?.name
        quantityLabel?.text = "\(detail.qty ?? 0)"
        wmsOrderCodeLabel?.text = detail.wmsOrderCode ?? "-"
        actualQuantityTextField?.text = (detail.loadedQty != nil) ? "\(detail.loadedQty!)" : ""
        vContent?.cornerRadius = 0
        customerNameLabel.text = Slash(order.customer?.userName)
        consigneeNameLabel.text = Slash(order.consigneeName)
        
        handleShowingCartonSection()
    }
    
    
    @IBAction func onLoadButtonTouchUp(_ sender: UIButton) {
        self.delegate?.didTouchOnLoadButton(self, detail: detail)
    }
    
}

//MARK: - UITEXTFIELD
extension LoadPackageTableViewCell: UITextFieldDelegate {
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        guard let palletTextField = actualQuantityTextField, let cartonTextField = actualCartonsInPalletTextField else { return }
//        let text =  textField.text ?? ""
//        if textField == palletTextField {
//            detail.loadedQty = Int(text)
////            delegate?.didEnterPalletsQuantityTextField(self, value: text, detail: self.detail)
//        } else if textField == cartonTextField {
//            detail.loadedCartonsInPallet = Int(text)
////            delegate?.didEnterCartonsQuantityTextField(self, value: text, detail: self.detail)
//        }
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            guard let palletTextField = actualQuantityTextField, let cartonTextField = actualCartonsInPalletTextField else { return true }
            if textField == palletTextField {
                detail.loadedQty = Int(updatedText)
            } else if textField == cartonTextField {
                detail.loadedCartonsInPallet = Int(updatedText)
            }
        }
        return true
    }
}
