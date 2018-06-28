

import UIKit
import ObjectMapper
import RealmSwift

class Cache: NSObject {
    static let shared = Cache()
    
    private let userDefaults = UserDefaults.standard
    
    var hasLogin:Bool {
        get{
            return getTokenKeyLogin() != nil
        }
    }

    var user:UserModel? {
        set (newValue){
            if let dic = newValue?.getJSONString() {
                setObject(obj: dic, forKey: Defaultkey.SF_USER)
            }else {
                userDefaults.removeObject(forKey: Defaultkey.tokenKey)
                userDefaults.removeObject(forKey: Defaultkey.SF_USER)

            }
        }
        
        get {
            
            if let dic = getObject(forKey: Defaultkey.SF_USER) as? ResponseDictionary{
                let userModel = Mapper<UserModel>().map(JSON: dic)
                return userModel
            }
           
            return nil
        }
    }
    
    var userLogin:UserLoginModel? {
        set {
            if let dic = newValue?.getJSONString() {
                setObject(obj: dic, forKey: Defaultkey.SF_REMEBER_LOGIN)
            }
        }
        
        get {
            
            if let dic = getObject(forKey: Defaultkey.SF_REMEBER_LOGIN) as? ResponseDictionary{
                let userLoginModel = Mapper<UserLoginModel>().map(JSON: dic)
                return userLoginModel
            }
            
            return nil
        }
    }
    
    
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
    
    func getTokenKeyLogin() -> String? {
        return user?.token
    }
}

