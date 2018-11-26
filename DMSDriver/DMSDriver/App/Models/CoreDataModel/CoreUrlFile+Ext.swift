//
//  CoreUrlFile+Ext.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 9/7/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation

//MARK: - CoreUrlFile
extension CoreUrlFile{
    func setAttributeFrom(_ urlFile: UrlFileMoldel)  {
    
        
    }
    
    func convertToUrlFileMoldel() -> UrlFileMoldel {
        let urlFile = UrlFileMoldel()
        urlFile.sig = sig?.convertToAttachfileModel()
        if let doc =  doc?.allObjects as? [CoreAttachFile] {
            doc.forEach { (file) in
                urlFile.doc?.append(file.convertToAttachfileModel())
            }
        }
        
        return urlFile
    }
}
