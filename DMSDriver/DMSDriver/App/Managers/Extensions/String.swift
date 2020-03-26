

import Foundation

extension String {
    static func className(aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }

    func substring(from: Int) -> String {
        let index = self.index(self.startIndex, offsetBy: from)
        return self.substring(from: index)
    }
    
    func parseToJSON() -> [String:Any]?{
        let data = self.data(using: .utf8)!
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String:AnyObject] else{
            return nil
        }
        
        return json
    }
    
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
  
    var length: Int {
        return self.count
    }

    static func random(length: Int = 20) -> String {

        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<length {
          let randomValue = arc4random_uniform(UInt32(base.count))
          let index = base.index(base.startIndex, offsetBy: Int(randomValue))
          randomString += "\(base[index])"
        }
        return randomString
    }
  
    var localized: String {
        let localBundle = Bundle(url: App().bundlePath)!
        return NSLocalizedString(self, tableName: nil, bundle: localBundle, value: "", comment: "")
    }
  
    var doubleValue: Double {
        return Double(self) ?? 0.0
    }
  
    var integerValue: Int {
        return Int(self) ?? 0
    }

    var url: URL? {
        return URL(string: self)
    }
    
    func encodeURL() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

    }
  
    var date: Date? {
//        return ServerDateFormater.date(from: self)
        return NormalDateFormater.date(from: self)
    }
    
    var time: Date? {
        return NormalTimeFormater.date(from: self)
    }
    
    var dateUS: Date? {
        return DateTimeUSWithSecond.date(from: self)
    }
    
    func replaceDoubleQuoteIfNeeded() -> String {
        return self.replacingOccurrences(of: "\"", with: "\\\"")
    }
    
    func rangeTime(_ toTime:String?,_ isOnlyDate: Bool = false) -> String {
        var rangeTime = ""
        var startTime = ""
        var endTime = ""
        if let start = self.date {
            startTime = isOnlyDate ? OnlyDateFormater.string(from: start) : ShortNormalDateFormater.string(from:start)
        }
        if let end = toTime?.date {
            endTime = isOnlyDate ? OnlyDateFormater.string(from: end) : ShortNormalDateFormater.string(from:end)
        }
        
        rangeTime = startTime + "\n" + endTime
        return rangeTime
    }
}
