//
//  SKUModel.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/20/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import Foundation
import ObjectMapper

class SKUModel: Order.Detail {
    var customers:[UserModel.UserInfo]?
    var uom:UOMModel?
    
    var itemContent:[String] = []
    var skuTitle:String = "sku".localized
    var skuStyle:DropDownType = .SKU
    var skuDataList:[SKUModel] = []
    var uomDataList:[UOMModel] = []
    var quantityTitle:String = "quantity".localized
    var qtyStyle:DropDownType = .Number
    var uomTitle:String = "uom".localized
    var uomStyle:DropDownType = .UOM
    var batchIdTitle:String = "batch-id".localized
    var batchIdStyle:DropDownType = .InputText
    var barcodeTitle:String = "Barcode".localized
    var barcodeStyle:DropDownType = .InputText
    
    
    var skuName: String {
        get {
            var _skuName = ""
            _skuName = refCode == nil ? Slash(self.name) : Slash(self.name) + " - " + Slash(self.refCode)
            return _skuName
        }
    }
    
    override init() {
        super.init()
    }

    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        customers <- map["customers"]
        uom <- map["uom"]
    }
    
    
    func createSKUItem(detail:Order.Detail, skuContent:String, skuDataList:[SKUModel], uomDataList:[UOMModel], qtyContent:String, uomContent:String, batchContent:String, barcodeContent:String) -> SKUModel {
        self.skuDataList = skuDataList
        self.uomDataList = uomDataList
        
        //add
        self.barCode = detail.barCode
        self.barcodeBool = detail.barcodeBool
        self.pivot = detail.pivot
        self.bcd = detail.bcd
        
        self.itemContent.append(skuContent)
        self.itemContent.append(qtyContent)
        self.itemContent.append(uomContent)
        self.itemContent.append(batchContent)
        self.itemContent.append(barcodeContent)
        return self
    }
    
    func createEditSKUItem(skuDataList:[SKUModel], uomDataList:[UOMModel]) -> SKUModel{
        self.skuDataList = skuDataList
        self.uomDataList = uomDataList
        let emptyText = ""
        self.itemContent.append(emptyText)
        self.itemContent.append(emptyText)
        self.itemContent.append(emptyText)
        self.itemContent.append(emptyText)
        self.itemContent.append(emptyText)
        return self
    }
}
