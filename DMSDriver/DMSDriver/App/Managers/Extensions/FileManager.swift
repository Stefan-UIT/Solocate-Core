//
//  FileManager.swift
//  DMSDriver
//
//  Created by Trung Vo on 6/27/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

extension FileManager {
    
    open func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }
    
}
