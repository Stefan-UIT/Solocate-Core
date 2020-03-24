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
    
    var itemContent:[String] = []
    var skuTitle:String = "sku".localized
    var skuStyle:DropDownType = .SKU
    var skuDataList:[SKUModel] = []
    var uomDataList:[UOMModel] = []
    var quantityTitle:String = "quantity".localized
    var qtyStyle:DropDownType = .InputText
    var uomTitle:String = "uom".localized
    var uomStyle:DropDownType = .UOM
    var batchIdTitle:String = "batchId".localized
    var batchIdStyle:DropDownType = .InputText
    
    
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
    }
    
    
    func createSKUItem(skuContent:String, skuDataList:[SKUModel], uomDataList:[UOMModel], qtyContent:String, uomContent:String, batchContent:String) -> SKUModel {
        self.skuDataList = skuDataList
        self.uomDataList = uomDataList
        self.itemContent.append(skuContent)
        self.itemContent.append(qtyContent)
        self.itemContent.append(uomContent)
        self.itemContent.append(batchContent)
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
        return self
    }
}
