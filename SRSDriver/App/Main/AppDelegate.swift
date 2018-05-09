//
//  AppDelegate.swift
//  SRSDriver
//
//  Created by phunguyen on 3/14/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import UserNotifications
import GoogleMaps
import SVProgressHUD
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    // Override point for customization after application launch.
    GMSServices.provideAPIKey(Network.googleAPIKey)
    SVProgressHUD.setDefaultMaskType(.clear)
    UNUserNotificationCenter.current().delegate = self
    
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: {_, _ in })
    application.registerForRemoteNotifications()
    
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
//    ThemeManager.applyTheme(.light)
    
    if let bundle = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist"),
        let dic = NSDictionary(contentsOf: bundle) {
        print("BUNDLE_ID - \(dic["BUNDLE_ID"] as! String)")
    }
    
    return true
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
}

extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    APIs.updateNotificationToken(fcmToken)
    Cache.shared.setObject(obj: fcmToken, forKey: Defaultkey.fcmToken)
    print("did receive fcm token \(fcmToken)")
  }
  
  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    print("didReceive remote message")
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    print("didReceive \(response)")
    if let userInfo = response.notification.request.content.userInfo as? [String: Any],
      let routeID = userInfo["route_id"] as? String {
      print("Route id \(routeID)")
      let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
      if let token = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String, token.length > 0 {
        // firstly, check stak
        if let currentNavController = window?.rootViewController as? UINavigationController,
          let tabbar = currentNavController.topViewController as? UITabBarController {
//          tabbar.selectedIndex = 0
          (tabbar.selectedViewController as? UINavigationController)?.popToRootViewController(animated: false)
          if let listNC = tabbar.viewControllers?.first as? UINavigationController,
            let listVC = listNC.viewControllers.first as? OrderListViewController {
            listVC.getRouteDetail(routeID)
          }
          if let type = userInfo["type"] as? String, type == "new message" {
            tabbar.selectedIndex = Constants.messageTabIndex
          }
          return
        }
        
        let rootNavigationController = mainStoryboard.instantiateInitialViewController() as? UINavigationController
        let tabbarVC = mainStoryboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController
        if let listNavigationController = tabbarVC?.viewControllers?.first as? UINavigationController,
          let listVC = listNavigationController.topViewController as? OrderListViewController {
          listVC.getRouteDetail(routeID)
        }
        if let type = userInfo["type"] as? String, type == "new message" {
          tabbarVC?.selectedIndex = Constants.messageTabIndex
        }
        rootNavigationController?.pushViewController(tabbarVC!, animated: true)
        window?.rootViewController = rootNavigationController
      }
      else {
        // Launch app normally
      }
    }
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler(.alert)
  }
  
}

