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
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var rootNV:BaseNV?
  var mainVC:MainVC?
  var navigationService = DMSNavigationService()

  
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")//disable autolayout error/warning
    
        let buildConfiguration = BuildConfiguration()
        // Debug server environment at here ex: .production,.development ...
        // Debug.setup(shared: Debug(useServer: DMSAppConfiguration.baseUrl_Dev)) // Use for Debug Only

        //App service
        Services.setupShared(buildConf: buildConfiguration)
        
        print(#"""
            ====>APPLICATION STARTED WITH:
            TagetBuild: \#(buildConfiguration.tagetBuild.rawValue)
            Server: \#(buildConfiguration.serverUrlString())
            <=====
            """#)
    
        GMSServices.provideAPIKey(Network.googleAPIKey)
        SVProgressHUD.setDefaultStyle(.dark)
   
        // Setup Push notifiaction
        registerPushNotification()
    
        //Setup Firebase
        SERVICES().firebase.setupFirebase()
 
        IQKeyboardManager.shared().isEnabled = true
        checkLoginStatus()
    
        // Follow Crashlytics app by Fabric
        Fabric.with([Crashlytics.self])
    
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //connectToFcm()
        // DMSLocationManager.startUpdatingDriverLocationIfNeeded()
        ReachabilityManager.startMonitoring()
        refreshBadgeIconNumber()
        if Caches().hasLogin &&
            SERVICES().socket.defaultSocket.status != .connected{
            SERVICES().socket.connect(token: E(Caches().user?.token))
        }
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
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DMSDriver")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

//MARK : - OTHER_FUNTION
extension AppDelegate {
    func checkLoginStatus() {
        if Caches().hasLogin {
            loginSuccess()
        }else {
            reLogin()
        }
    }
    
    func reLogin() {
        invalidTimer()
        let vc: LoginViewController = .loadSB(SB: .Login)
        window?.rootViewController = vc
        let loginSocket = SERVICES().socket.socketWithNamespace(.login)
        if loginSocket.status == .connected{
           SERVICES().socket.logout(Caches().user?.userInfo?.id ?? 0,
                                     E(Caches().user?.roles?.first?.name))
        }
        SERVICES().socket.disconnect()

        CoreDataManager.clearAllDB()
        Caches().drivingRule = nil
        Caches().timePlaying = 0
        Caches().isPauseRoute = false
        Caches().isStartingRoute = false
        Caches().isCancelCounter = true
        Caches().dateStartRoute = nil
        Caches().datePauseRoute = nil
        mainVC?.endAutoRefetchRouteList()
    }
    
    func loginSuccess() {
        if SERVICES().socket.defaultSocket.status != .connected{
            SERVICES().socket.connect(token: E(Caches().user?.token))
        }
        
        DMSLocationManager.startUpdatingDriverLocationIfNeeded()
        ReachabilityManager.startMonitoring()
        ReachabilityManager.updateAllRequestToServer()
        if let tokenFcm = Caches().getObject(forKey: Defaultkey.fcmToken) as? String {
            SERVICES().API.updateNotificationFCMToken(tokenFcm) { (_) in}
        }
        let _rootNV:BaseNV = .loadSB(SB: .Main)
        rootNV = _rootNV
        mainVC = rootNV?.viewControllers.first as? MainVC
        navigationService.navigationItem = App().mainVC?.navigationItem
        navigationService.navigationBar = App().mainVC?.navigationController?.navigationBar
        window?.rootViewController = _rootNV
    }

    func invalidTimer()  {
        App().mainVC?.rootNV?.viewControllers.forEach({ (vc) in
            if let _vc = vc as? TimerVC {
                _vc.invalidTimmer()
                return
            }
        })
    }
}
