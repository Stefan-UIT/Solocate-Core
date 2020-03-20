//
//  BusinessOrderPickerTableViewCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/18/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import UIKit

protocol BusinessOrderPickerTableViewCellDelegate:class {
    func didSelectedDopdown(_ cell:BusinessOrderPickerTableViewCell,_ btn:UIButton , style:DropDownType ,indexPath:IndexPath,_ data:[String],_ titleContent:String)
    
}

struct BusinessOrderForRow {
    var title: String = ""
    var content: String = ""
    var isHighlight = false
    var textColor:UIColor?
    var isEditingBO = false
    var style:DropDownType
    var data:[String] = []
    var isRequire:Bool = false
    
    init(title:String , content:String, _ isHighlight:Bool = false, _ textColor:UIColor? = nil, isEditing:Bool, style:DropDownType, _ data:[String]? = [],isRequire:Bool) {
        self.title = title
        self.content = content
        self.isHighlight = isHighlight
        self.textColor = textColor
        self.isEditingBO = isEditing
        self.style = style
        self.data = data ?? []
        self.isRequire = isRequire
    }
}

class BusinessOrderPickerTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var contentLabel: UILabel?
    @IBOutlet weak var vContent: UIView?
    @IBOutlet weak var btnDropDown: UIButton?
    @IBOutlet weak var iconDropDown: UIButton!
    @IBOutlet weak var contentEditLabel: UILabel?
    @IBOutlet weak var editContainerView: UIView!
    
    weak var delegate:BusinessOrderPickerTableViewCellDelegate?
    var indexPath:IndexPath?
    var isEditingBO: Bool = false
    var isRequire: Bool = false
    var orderDetailItem: BusinessOrderForRow! {
        didSet {
            setupView(item: orderDetailItem)
        }
    }
    var dropDownType:DropDownType?
    var dataContent:[String]?
    var titleContent:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel?.numberOfLines = 0
    }
    
    private func setupView(item: BusinessOrderForRow) {
        isRequire = item.isRequire
        titleContent = item.title
        dataContent = item.data
        dropDownType = item.style
        nameLabel?.text = item.title
        contentLabel?.textColor = item.isHighlight ? AppColor.buttonColor : AppColor.black
        iconDropDown.tintColor = AppColor.greenColor
        isEditingBO = item.isEditingBO
        if isEditingBO {
            vContent?.backgroundColor = isRequire ? AppColor.white : AppColor.grayColor
            let displayMessage = dropDownType == DropDownType.Option ? "please-select" : "tap-to-edit"
            let textString = (item.content == "-" || item.content == "") ? displayMessage : item.content
            contentEditLabel?.text = textString
            contentEditLabel?.textColor = AppColor.greenColor
        } else {
            contentLabel?.text = item.content
        }
        if let color = item.textColor {
            contentLabel?.textColor = color
        }
        editContainerView?.isHidden = !isEditingBO
        btnDropDown?.isHidden = !isEditingBO
        contentEditLabel?.isHidden = !isEditingBO
        contentLabel?.isHidden = isEditingBO
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onbtnClickDropdown(btn:UIButton){
        guard let _indexPath = indexPath, let _style = dropDownType, let _data = dataContent, let _title = titleContent else { return }
        delegate?.didSelectedDopdown(self, btn, style: _style, indexPath: _indexPath, _data, _title)
    }

}
