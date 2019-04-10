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

  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")//disable autolayout error/warning
    
        // Config server environment at here ex: .production,.development ...
        let buildConfiguration = BuildConfiguration(serverEnvironment: .development)
        
        Debug.setup(shared: Debug(buildConf: buildConfiguration)) // Use for Debug Only

        //App service
        Services.setupShared(buildConf: buildConfiguration)
        
        print(#"""
            ==>APPLICATION STARTED WITH:
            Server-\#(buildConfiguration.serverEnvironment.displayString())-\#(buildConfiguration.serverUrlString())
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
                    
                case .ALERT_RESOLVE:
                    reloadOrPushScreenHistoryNotificationVC()
                }
            }
        }
    
        completionHandler()
    }
    
    func reloadOrPushScreenHistoryNotificationVC() {
        let lastVC = App().mainVC?.rootNV?.viewControllers.last
        if lastVC is TaskDetailVC{
            (lastVC as? HistoryNotifyVC)?.fetchData(showLoading: false)
            
        }else{
            let vc:HistoryNotifyVC = .loadSB(SB: .Notification)
            App().mainVC?.rootNV?.setViewControllers([vc], animated: false)
        }
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
    
    App().mainVC?.refetchDataRouteOrTaskListOrHistoryNotify()
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
    var statusBarView: UIView? {
        return UIApplication.shared.value(forKey: "statusBar") as? UIView
    }
    
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
    
    func invalidTimer()  {
        App().mainVC?.rootNV?.viewControllers.forEach({ (vc) in
            if let _vc = vc as? TimerVC {
                _vc.invalidTimmer()
                return
            }
        })
    }
}
