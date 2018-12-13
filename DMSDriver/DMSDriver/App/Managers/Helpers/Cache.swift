

import UIKit
import ObjectMapper

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
                userDefaults.removeObject(forKey: Defaultkey.SF_USER)
                userDefaults.removeObject(forKey: Defaultkey.tokenKey)
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
    
    var drivingRule:DrivingRule?{
        set {
            if let dic = newValue?.getJSONString() {
                setObject(obj: dic, forKey: Defaultkey.SF_DRIVING_RULE)
            }
        }
        
        get {
            
            if let dic = getObject(forKey: Defaultkey.SF_DRIVING_RULE) as? ResponseDictionary{
                let drivingRule = Mapper<DrivingRule>().map(JSON: dic)
                return drivingRule
            }
            
            return nil
        }
    }
    
    var dateStartRoute:Date? {
        set {
            if let date = newValue {
                setObject(obj: date, forKey: Defaultkey.SF_SAVE_DATE_START_ROUTE)
            }
        }
        
        get {
            
            if let date = getObject(forKey: Defaultkey.SF_SAVE_DATE_START_ROUTE) as? Date{
                return date
            }
            
            return nil
        }
    }
    
    var datePauseRoute:Date? {
        set {
            if let date = newValue {
                setObject(obj: date, forKey: Defaultkey.SF_PAUSE_DATE_ROUTE)
            }else {
                userDefaults.removeObject(forKey: Defaultkey.SF_PAUSE_DATE_ROUTE)
            }
        }
        
        get {
            
            if let date = getObject(forKey: Defaultkey.SF_PAUSE_DATE_ROUTE) as? Date{
                return date
            }
            
            return nil
        }
    }
    
    var isStartingRoute:Bool{
        set{
            setObject(obj: newValue, forKey: Defaultkey.starting)
        }
        
        get{
            if let data = getObject(forKey: Defaultkey.starting) as? Bool{
                return data
            }
            return false
        }
    }
    
    var isPauseRoute:Bool{
        set{
            setObject(obj: newValue, forKey: Defaultkey.pause)
        }
        
        get{
            if let data = getObject(forKey: Defaultkey.pause) as? Bool{
                return data
            }
            return false
        }
    }
    
    var isCancelCounter:Bool{
        set{
            setObject(obj: newValue, forKey: Defaultkey.cancel)
        }
        
        get{
            if let data = getObject(forKey: Defaultkey.cancel) as? Bool{
                return data
            }
            return false
        }
    }
    
    var timePlaying:Int{
        set{
            setObject(obj: newValue, forKey: Defaultkey.timePlaying)
        }
        
        get{
            if let data = getObject(forKey: Defaultkey.timePlaying) as? Int{
                return data
            }
            
            return 0
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

