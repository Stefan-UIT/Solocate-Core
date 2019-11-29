//
//  CoreReason+Ext.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 9/7/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation

//MARK: - CoreReason
extension CoreReason{
    func setAttributeFrom(_ reason: Reason? = nil)  {
        guard let _reason = reason else {
            return
        }
        id = Int32(_reason.id)
        message = _reason.message
        reasonDescription = _reason.reasonDescription
        name = _reason.name
        catalogId = Int16(_reason.catalog?.id ?? 0)
        catalogName = _reason.catalog?.name
        catalogCode = _reason.catalog?.code
    }
    
    func convertToReasonOrderCC() -> Reason {
        let reason = Reason()
        reason.id = Int(id)
        reason.message = message
        reason.reasonDescription = E(reasonDescription)
        reason.name = E(name)
        let _catalog = Catalog()
        _catalog.id = Int(catalogId)
        _catalog.name = catalogName
        _catalog.code = catalogCode
        
        reason.catalog = _catalog
        return reason
    }
}
