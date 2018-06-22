

import UIKit
import RealmSwift

class Cache: NSObject {
    static let shared = Cache()
    
    private let userDefaults = UserDefaults.standard
    
    func setObject(obj: Any, forKey key: String) {
        let data = NSKeyedArchiver.archivedData(withRootObject: obj)
        userDefaults.set(data, forKey: key)
        userDefaults.synchronize()
    }
    
    func getObject(forKey key: String) -> Any? {
        if let data = userDefaults.object(forKey: key) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as AnyObject?
        } else {
            return nil
        }
    }
    
    class func getTokenKeyLogin() -> String? {
        guard let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String else {
            return nil
        }
        return token
    }
    
    class func setTokenKeyLogin(_ token: String) {
        Cache.shared.setObject(obj: token, forKey: Defaultkey.tokenKey)
    }
}
