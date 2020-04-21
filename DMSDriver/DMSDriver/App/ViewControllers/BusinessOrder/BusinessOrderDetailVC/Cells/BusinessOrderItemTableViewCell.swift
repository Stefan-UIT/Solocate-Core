//
//  BusinessOrderItemTableViewCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/19/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import UIKit

protocol BusinessOrderItemTableViewCellDelegate: NSObjectProtocol {
    func didSelectedDopdown(_ cell:BusinessOrderItemTableViewCell,_ btn:UIButton , style:DropDownType,_ itemDropDown:DropDownModel?,_ titleContent:String,tag:Int, indexPath: IndexPath)
    func didSelectShowBarcode()
}

class BusinessOrderItemTableViewCell: UITableViewCell {

    
    @IBOutlet weak var skuEditContentView: UIView!
    @IBOutlet weak var quantityEditContentView: UIView!
    @IBOutlet weak var uomEditContentView: UIView!
    @IBOutlet weak var batchIdEditContentView: UIView!
    @IBOutlet weak var barcodeContentView: UIView!
    
    
    @IBOutlet weak var skulabel: UILabel!
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var uomLabel: UILabel!
    @IBOutlet weak var batchIdLbl: UILabel!
    @IBOutlet weak var barecodeLbl: UILabel!
    
    
    @IBOutlet weak var skuContentLabel: UILabel!
    @IBOutlet weak var quantityContentLabel: UILabel!
    @IBOutlet weak var uomContentLabel: UILabel!
    @IBOutlet weak var batchIdContentLbl: UILabel!
    @IBOutlet weak var barcodeContentLbl: UILabel!
    
    @IBOutlet weak var showBarcodeView: UIView!
    @IBOutlet weak var barecodeView: UIView!
    
    @IBOutlet weak var showBarcodeButton: UIButton!
    
    
    @IBOutlet var iconButtons:[UIButton]!
    
    @IBOutlet var requireLabel: [UILabel]!
    
    weak var delegate: BusinessOrderItemTableViewCellDelegate?
    var item:SKUModel? {
        didSet {
            configureCell(item: item!)
        }
    }
    var isEditingBO:Bool = false
    let SKU_CONTENT_INDEX:Int = 0
    let QTY_CONTENT_INDEX:Int = 1
    let UOM_CONTENT_INDEX:Int = 2
    let BATCH_CONTENT_INDEX:Int = 3
    let BARCODE_INDEX:Int = 4
    var indexPath:IndexPath?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(item:SKUModel) {
        let itemContentNumber = item.itemContent.count
        if  itemContentNumber < 5 || itemContentNumber > 5 {
            return
        }
        skuEditContentView.isHidden = !isEditingBO
        quantityEditContentView.isHidden = !isEditingBO
        uomEditContentView.isHidden = !isEditingBO
        batchIdEditContentView.isHidden = !isEditingBO
        showBarcodeView.isHidden = !isEditingBO
        barecodeView.isHidden = !showBarcodeButton.isSelected
        barcodeContentView.isHidden = !isEditingBO
        
        skulabel.isHidden = isEditingBO
        quantityLbl.isHidden = isEditingBO
        uomLabel.isHidden = isEditingBO
        batchIdLbl.isHidden = isEditingBO
        barecodeLbl.isHidden = isEditingBO
        
        for (_,label) in requireLabel.enumerated() {
            label.isHidden = !isEditingBO
        }
        
        let skuContent =  item.itemContent[SKU_CONTENT_INDEX]
        let qtyContent = item.itemContent[QTY_CONTENT_INDEX]
        let uomContent = item.itemContent[UOM_CONTENT_INDEX]
        let batchContent = item.itemContent[BATCH_CONTENT_INDEX]
        var barcodeContent = ""
        if showBarcodeButton.isSelected {
            barcodeContent = item.itemContent[BARCODE_INDEX]
        }
        
        if isEditingBO {
            for (_,button) in iconButtons.enumerated() {
                button.tintColor = AppColor.greenColor
            }
            skuContentLabel.textColor = AppColor.greenColor
            quantityContentLabel.textColor = AppColor.greenColor
            uomContentLabel.textColor = AppColor.greenColor
            batchIdContentLbl.textColor = AppColor.greenColor
            barcodeContentLbl.textColor = AppColor.greenColor
            let SELECT_TEXT = "please-select".localized
            let TAP_EDIT_TEXT = "tap-to-edit".localized
            skuContentLabel.text = (skuContent == "-" || skuContent == "") ? SELECT_TEXT : skuContent
            quantityContentLabel.text = (qtyContent == "-" || qtyContent == "" ) ? TAP_EDIT_TEXT : qtyContent
            uomContentLabel.text = (uomContent == "-" || uomContent == "") ? "-" : uomContent
            batchIdContentLbl.text = (batchContent == "-" || batchContent == "") ? TAP_EDIT_TEXT : batchContent
            barcodeContentLbl.text = (barcodeContent == "-" || barcodeContent == "") ? TAP_EDIT_TEXT : barcodeContent
        } else {
            barcodeContent = item.itemContent[BARCODE_INDEX]
            barecodeView.isHidden = false
            barecodeView.isHidden = barcodeContent == ""
            skulabel.text = skuContent
            quantityLbl.text = qtyContent
            uomLabel.text = uomContent
            batchIdLbl.text = batchContent
            barecodeLbl.text = barcodeContent
        }
    }
    
    
    @IBAction func didTapSKUDropDown(_ sender: UIButton) {
        guard let _item = item, let _indexPath = indexPath else { return }
        let itemDropDown = DropDownModel()
        itemDropDown.skus = _item.skuDataList
        self.delegate?.didSelectedDopdown(self, sender, style: _item.skuStyle, itemDropDown, _item.skuTitle, tag: SKU_CONTENT_INDEX, indexPath: _indexPath)
    }
    
    @IBAction func didTapQuantityDropDown(_ sender: UIButton) {
        guard let _item = item, let _indexPath = indexPath else { return }
        self.delegate?.didSelectedDopdown(self, sender, style: _item.qtyStyle, nil, _item.quantityTitle, tag: QTY_CONTENT_INDEX, indexPath: _indexPath)
    }
    
    @IBAction func didTapUOMDropDown(_ sender: UIButton) {
//        guard let _item = item,  let _indexPath = indexPath else { return }
//        let itemDropDown = DropDownModel()
//        itemDropDown.uoms = _item.uomDataList
//        self.delegate?.didSelectedDopdown(self, sender, style: _item.uomStyle, itemDropDown, _item.uomTitle, tag: UOM_CONTENT_INDEX, indexPath: _indexPath)
    }
    
    @IBAction func didTapBatchDropDown(_ sender: UIButton) {
        guard let _item = item, let _indexPath = indexPath else { return }
        self.delegate?.didSelectedDopdown(self, sender, style: _item.batchIdStyle, nil, _item.batchIdTitle, tag: BATCH_CONTENT_INDEX, indexPath: _indexPath)
    }
    @IBAction func didTapShowBarcodeButton(_ sender: Any) {
        showBarcodeButton.isSelected = !showBarcodeButton.isSelected
        self.delegate?.didSelectShowBarcode()
    }

    @IBAction func didTapBarcodeDropDown(_ sender: UIButton) {
        guard let _item = item, let _indexPath = indexPath else { return }
        self.delegate?.didSelectedDopdown(self, sender, style: _item.barcodeStyle, nil, _item.barcodeTitle, tag: BARCODE_INDEX, indexPath: _indexPath)
    }
    
    
}
