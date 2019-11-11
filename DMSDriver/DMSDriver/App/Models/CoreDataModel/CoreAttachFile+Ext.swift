//
//  CoreAttachFile+Ext.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 9/7/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation

//MARK: - CoreAttachFile
extension CoreAttachFile{
    func setAttributeFrom(_ attachFile: AttachFileModel)  {
        let image = UIImage(named: "place_holder")
        contentFile = image?.pngData()
        id = Int32(attachFile.id)
        name = attachFile.name
        type = attachFile.type
        url = attachFile.url
        urlThumbnail = attachFile.url_thumbnail
    }
    
    func convertToAttachfileModel() -> AttachFileModel {
        let file = AttachFileModel()
        file.id = Int(id)
        file.name = name
        file.type = type
        file.url = url
        file.url_thumbnail = urlThumbnail
        file.contentFile = contentFile
        
        return file
    }
}
