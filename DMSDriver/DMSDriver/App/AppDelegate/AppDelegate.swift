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
import IQKeyboardManager
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var rootNV:BaseNV?
  var mainVC:MainVC?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")//disable autolayout error/warning
    
        //Load data in configfile (Main,Service configuration)
        DMSAppConfiguration.enableConfiguration()
    
        // App services
        guard let buildConfiguration = BuildConfiguration(infoDictionary: Bundle.main.infoDictionary!) else {
            fatalError("Invalid configuration. App stops.");
        }

        Debug.setup(shared: Debug(buildConf: buildConfiguration))
        Services.setupShared(buildConf: buildConfiguration)

        print("\n==>APPLICATION STARTED WITH: \n\tScheme-\(buildConfiguration.buildScheme.rawValue);\n\tServer-\(buildConfiguration.serverEnvironment.displayString())-\(buildConfiguration.serverUrlString()) \n")
    
        GMSServices.provideAPIKey(Network.googleAPIKey)
        SVProgressHUD.setDefaultMaskType(.clear)
   
        // Setup Push notifiaction
        registerPushNotification()
    
        //Setup Firebase
        SERVICES().firebase.setupFirebase()
 
        IQKeyboardManager.shared().isEnabled = true
        checkLoginStatus()
    
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //connectToFcm()
        // DMSLocationManager.startUpdatingDriverLocationIfNeeded()
        refreshBadgeIconNumber()
    }
  
    //MARK: - PUSH NOTIFICATION
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X",    $1)})
        print("DEVICE TOKEN: \( tokenString )")
        
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error Register Remote Notification:\(error)")
    }
}


//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //Handle User tap notification messages while app is in the foreground.
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    print("==>Did Receive Response: \(response)")
    
    // Handle Tap
    completionHandler()

  }
  
  //Receive displayed notifications for iOS 10 devices.
  // Setup to show .alert,.badge,.sound  while app is in the foreground.
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo as? [String: Any]
    print("===>Will Present Notification: \(userInfo ?? [:])")
    
    //With swizzling disabled you must let Messaging know about the message, for Analytics
    //Messaging.messaging().appDidReceiveMessage(notification.request.content.userInfo)
    
    //Currently only push remote route
    App().mainVC?.refetchDataRouteList()
    completionHandler([.alert,.badge,.sound])
  }
}


//MARK: - AlertMessageViewDelegate
extension AppDelegate: AlertMessageViewDelegate {
    func alertMessageView(_ alertMessageView: AlertMessageView, _ alertID: String, _ content: String) {
        //
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Done", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        if let viewController = window?.rootViewController {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}


//MARK : - OTHER_FUNTION
extension AppDelegate {
    
    func checkLoginStatus() {
        rootNV = window?.rootViewController as? BaseNV
        
        if Caches().hasLogin {
            loginSuccess()
        }else {
            reLogin()
        }
    }
    
    func registerPushNotification()  {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    
    func reLogin() {
        let vc: LoginViewController = .loadSB(SB: .Login)
        rootNV?.setViewControllers([vc], animated: false)
        Caches().user = nil
    }
    
    func loginSuccess() {
        DMSLocationManager.startUpdatingDriverLocationIfNeeded()
        if let tokenFcm = Caches().getObject(forKey: Defaultkey.fcmToken) as? String {
            API().updateNotificationFCMToken(tokenFcm) { (_) in}
        }
        
        let vc:MainVC = .loadSB(SB: .Main)
        mainVC = vc
        rootNV?.setViewControllers([vc], animated: false)
    }
    
    func handleNewRoute(_ userInfo: [String: Any]) {
        if let routeID = userInfo["route_id"] as? String {
            print("PUSH_NOTIFICATION: routeID = \(routeID)")
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
    
    func handleAlert(_ userInfo: [String: Any]) {
        guard let alertID = userInfo["alert_id"] as? String  else {
            return
        }
        
        guard let messageAlert = userInfo["title"] as? String  else {
            return
        }
        let alertMessageView : AlertMessageView = AlertMessageView()
        alertMessageView.delegate = self
        alertMessageView.config(alertID, messageAlert)
        alertMessageView.showViewInWindow()
    }
    
    func refreshBadgeIconNumber()  {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = notifications.count
            }
        }
    }
}
