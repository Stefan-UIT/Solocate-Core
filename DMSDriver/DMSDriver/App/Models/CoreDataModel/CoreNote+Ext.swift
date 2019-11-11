//
//  CoreNote+Ext.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 11/11/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

extension CoreNote {
    func setAttributeFrom(_ note: Note)  {
        id = Int16(note.id)
        content = note.content
        userId = Int16(note.createdBy.id)
        userName = note.createdBy.userName
        statusId = Int16(note.status?.id ?? 0)
        statusName = note.status?.name
        statusCode = note.status?.code
        noteFile?.addingObjects(from: note.files)
    }
    
    func convertToNoteModel() -> Note {
        let note = Note()
        note.id = Int(id)
        note.content = content ?? ""
        
        let createdByJSON = ["id":Int(userId), "username": (userName ?? "")] as [String:Any]
        let _createdBy = UserModel.UserInfo(JSON: createdByJSON)
        note.createdBy = _createdBy
        
        let _status = Status()
        _status.id = Int(statusId)
        _status.name = statusName
        _status.code = statusCode
        note.status = _status
        
        var coreFile = [AttachFileModel]()
        if let file = noteFile?.allObjects as? [CoreAttachFile] {
            file.forEach{ (file) in
                coreFile.append(file.convertToAttachfileModel())
            }
        }
        note.files = coreFile
        
        return note
    }
}
