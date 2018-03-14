

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
  
//  func getUser() -> User? {
//    let realm = try? Realm()
//    if let user = realm?.objects(User.self).first {
//      return user
//    }
//    return nil
//  }
//
//  func save(_ user: User) {
//    let realm = try! Realm()
//    try! realm.write {
//      realm.add(user)
//    }
//  }
//
//  func updateUserStatus(_ status: Bool) {
//    if let user = getUser() {
//      let realm = try! Realm()
//      try! realm.write {
//        user.status = status ? "1" : "0"
//      }
//    }
//  }
//
//  func updateUserAvatar(_ avatarString: String) {
//    if let user = getUser() {
//      let realm = try! Realm()
//      try! realm.write {
//        user.picture = avatarString
//      }
//    }
//  }
//
//  func updateUserInfo(_ info: User) {
//    if let user = getUser() {
//      let realm = try! Realm()
//      try! realm.write {
//        user.firstName = info.firstName
//        user.lastName = info.lastName
//        user.status = info.status
//      }
//    }
//  }
//
//
//  func deleteCurrentUser() {
//    let realm = try! Realm()
//    let user = realm.objects(User.self)
//    try! realm.write {
//      realm.delete(user)
//    }
//  }
  
}
