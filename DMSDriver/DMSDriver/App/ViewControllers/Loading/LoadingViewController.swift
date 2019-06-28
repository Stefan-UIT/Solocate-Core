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
//            self.fakeFilePath(language: lang)
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
    
    func fakeFilePath(language:LanguageModel) {
        language.path = (language.locale == "en") ? "https://seldat-dev-public.s3.amazonaws.com/solocate-a1/develop/language/dms/ios/en.strings" : "https://seldat-dev-public.s3.amazonaws.com/solocate-a1/develop/language/dms/ios/he.strings"
    }
    
    func downloadFileFrom(name:String, path:String, saveTo destination:URL, withCompletionHandler
        completion:@escaping DownloadedFilesCompletion) {
        let des: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileURL = destination.appendingPathComponent("Localizable.strings")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
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
        
//        Alamofire.download(path, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, to: des).responseData(completionHandler: { (result) in
//            print("Download successful! \(result.result)")
//            completion()
//        })
    }
    
    func convertToStringsFile(dict:[String:String], saveTo destination:URL) {
        let res = dict.reduce("", { $0 + "\"\($1.key)\" = \"\(($1.value).replaceDoubleQuoteIfNeeded())\";\n" })
        let filePath = destination.appendingPathComponent("Localizable.strings")
        let data = res.data(using: .utf32)
        FileManager.default.createFile(atPath: filePath.path, contents: data, attributes: nil)
    }
    
}

//      ($1.key)\" = \"\($1.value)\";\n
