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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var rootNV:BaseNV?
  var mainVC:MainVC?
  var navigationService = DMSNavigationService()

  
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
        SVProgressHUD.setDefaultStyle(.dark)
   
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
        ReachabilityManager.startMonitoring()
        APISocket.shared.establishConnection()
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


//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //Handle User tap notification messages while app is in the foreground.
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle Tap
        if let userInfo = response.notification.request.content.userInfo as? [String: Any]{
            print("==>Did Receive Response: \(userInfo)")
            
            if let noti = ReceiveNotificationModel(JSON: userInfo){
                switch noti.notiType{
                case .TASK:
                    let task = TaskModel()
                    task.task_id = noti.object_data?.object_id
                    self.reloadOrPushScreenTaskDetailVC(task)
                    
                case .ROUTE:
                    
                    let route = Route()
                    route.id = noti.object_data?.object_id ?? -1
                    self.reloadOrPushScreenRouteDetail(route)
                    
                case .ROUTE_LIST:
                    break
                }
            }
        }
    
        completionHandler()
  }
    
    
    func reloadOrPushScreenTaskDetailVC(_ task: TaskModel) {
        let lastVC = App().mainVC?.rootNV?.viewControllers.last
        if lastVC is TaskDetailVC{
            (lastVC as? TaskDetailVC)?.fetchData()
            
        }else{
            let vc: TaskDetailVC = .loadSB(SB: .Task)
            vc.task = task
            App().mainVC?.rootNV?.pushViewController(vc, animated: true)
        }
    }
    
    func reloadOrPushScreenRouteDetail(_ route: Route){
        let vc:RouteDetailVC = .loadSB(SB: .Route)
        vc.route = route;
        vc.dateStringFilter = route.date
        App().mainVC?.rootNV?.pushViewController(vc, animated: true)
    }
    
    
  
  //Receive displayed notifications for iOS 10 devices.
  // Setup to show .alert,.badge,.sound  while app is in the foreground.
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo as? [String: Any]
    print("===>Will Present Notification: \(userInfo ?? [:])")
    
    //With swizzling disabled you must let Messaging know about the message, for Analytics
    //Messaging.messaging().appDidReceiveMessage(notification.request.content.userInfo)
    
    App().mainVC?.refetchDataRouteOrTaskList()
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
        let cancelAction = UIAlertAction(title: "ok".localized, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        if let viewController = window?.rootViewController {
            viewController.present(alert, animated: true, completion: nil)
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
    
    func registerPushNotification()  {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
        }
    }
    
    
    func reLogin() {
        let vc: LoginViewController = .loadSB(SB: .Login)
        window?.rootViewController = vc
        //Socket.logout(Caches().user?.userInfo?.id ?? 0, E(Caches().user?.roles?.first?.name))
        CoreDataManager.clearAllDB()
        Caches().user = nil
        mainVC?.endAutoRefetchRouteList()
    }
    
    func loginSuccess() {
        DMSLocationManager.startUpdatingDriverLocationIfNeeded()
        ReachabilityManager.startMonitoring()
        ReachabilityManager.updateAllRequestToServer()
        if let tokenFcm = Caches().getObject(forKey: Defaultkey.fcmToken) as? String {
            API().updateNotificationFCMToken(tokenFcm) { (_) in}
        }
        let _rootNV:BaseNV = .loadSB(SB: .Main)
        rootNV = _rootNV
        mainVC = rootNV?.viewControllers.first as? MainVC
        navigationService.navigationItem = App().mainVC?.navigationItem
        window?.rootViewController = _rootNV
    }

    func showAlertView(_ title:String? = nil, _ message: String? = nil,
                       positiveTitle: String? = nil,
                       positiveAction:((_ action: UIAlertAction) -> Void)? = nil,
                       negativeTitle: String? = nil,
                       negativeAction: ((_ action: UIAlertAction) -> Void)? = nil)  {
        let alert = UIAlertController(title: E(title), message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: isEmpty(positiveTitle) ? "OK".localized : positiveTitle, style: .default, handler: positiveAction)
        if negativeAction != nil {
            let cancelAction = UIAlertAction(title: isEmpty(negativeTitle) ? "Cancel".localized : negativeTitle, style: .cancel, handler: negativeAction)
            alert.addAction(cancelAction)
        }
        alert.addAction(okAction)
        App().mainVC?.present(alert, animated: true, completion: nil)
    }
    
    func refreshBadgeIconNumber()  {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = notifications.count
            }
        }
    }
}
