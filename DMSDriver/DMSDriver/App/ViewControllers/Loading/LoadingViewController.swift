//
//  LoadingViewController.swift
//  DMSDriver
//
//  Created by Trung Vo on 6/27/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import Alamofire

class LoadingViewController: UIViewController {
    typealias DownloadedFilesCompletion = () -> Void
    var languages:[LanguageModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMultiLanguageFiles()
        // Do any additional setup after loading the view.
    }
    
    func fetchMultiLanguageFiles() {
        self.showLoadingIndicator()
        SERVICES().API.getLanguagesList { (result) in
            switch result{
            case .object(let obj):
                self.languages = obj.data ?? []
                self.downloadFiles {
                    self.appCheckLoginSuccess()
                }
            case .error(let error):
                print(error.description)
            }
        }
        
    }
    
    func appCheckLoginSuccess() {
        self.dismissLoadingIndicator()
        App().checkLoginStatus()
    }
    
    func downloadFiles(withCompletionHandler completion:@escaping DownloadedFilesCompletion) {
        let manager = FileManager.default
        let downloadGroup = DispatchGroup()
        
        for lang in self.languages {
            let destination = App().bundlePath.appendingPathComponent("\(lang.locale).lproj", isDirectory: true)
            if manager.fileExists(atPath: destination.path) == false {
                do {
                    try manager.createDirectory(at: destination, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error)
                }
            }

            downloadGroup.enter()
            self.downloadFileFrom(name: lang.locale, path: lang.path, saveTo: destination) {
                downloadGroup.leave()
            }
        }
        downloadGroup.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
    
    func downloadFileFrom(name:String, path:String, saveTo destination:URL, withCompletionHandler
        completion:@escaping DownloadedFilesCompletion) {
        
        Alamofire.request(path, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { (dataResponse) in
            switch dataResponse.result {
            case .success(let object):
                if let dict = object as? [String:String] {
                    self.convertToStringsFile(dict: dict, saveTo: destination)
                }
                completion()
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func convertToStringsFile(dict:[String:String], saveTo destination:URL) {
        let res = dict.reduce("", { $0 + "\"\($1.key)\" = \"\(($1.value).replaceDoubleQuoteIfNeeded())\";\n" })
        let filePath = destination.appendingPathComponent("Localizable.strings")
        let data = res.data(using: .utf32)
        FileManager.default.createFile(atPath: filePath.path, contents: data, attributes: nil)
    }
    
}
