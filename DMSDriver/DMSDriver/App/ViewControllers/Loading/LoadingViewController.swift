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

    override func viewDidLoad() {
        super.viewDidLoad()
        createMultiLanguageFile()
        // Do any additional setup after loading the view.
    }
    
    func createMultiLanguageFile() {
        let manager = FileManager.default
        
        SERVICES().API.getLanguagesList { (result) in
            switch result{
            case .object(let obj):
                var languages:[LanguageModel]!
                languages = obj.data ?? []
                
                for lang in languages {
                    self.fakeFilePath(language: lang)
                    let destination = App().bundlePath.appendingPathComponent("\(lang.locale).lproj", isDirectory: true)
                    if manager.fileExists(atPath: destination.path) == false {
                        do {
                            try manager.createDirectory(at: destination, withIntermediateDirectories: true, attributes: nil)
                        } catch {
                            print(error)
                        }
                    }
                    self.downloadFileFrom(name:lang.locale, path: lang.path, saveTo: destination)
                    // use dispatch group, after all sucessful then checklogin.
                }
            case .error(let error):
                print(error.description)
            }
        }
        
    }
    
    func fakeFilePath(language:LanguageModel) {
        language.path = (language.locale == "en") ? "https://seldat-dev-public.s3.amazonaws.com/solocate-a1/develop/language/dms/ios/en.strings" : "https://seldat-dev-public.s3.amazonaws.com/solocate-a1/develop/language/dms/ios/he.strings"
    }
    
    func downloadFileFrom(name:String, path:String, saveTo destination:URL) {
        let des: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileURL = destination.appendingPathComponent("Localizable.strings")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(path, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, to: des).response { (response) in
            print("Download successful! \(response)")
            
        }
    }
    
    func hebrewLanguage() -> LanguageModel {
        let json:[String:Any] = ["id": 3,
                                 "name": "ios",
                                 "system": "DMS",
                                 "locale": "he",
                                 "path": "https://seldat-dev-public.s3.amazonaws.com/solocate-a1/develop/language/dms/ios/he.strings",
                                 "format": "json",
                                 "ac": 1,
                                 "language": "hebrew"
        ]
        
        return LanguageModel(JSON: json)!
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
