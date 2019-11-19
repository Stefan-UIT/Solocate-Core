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
 import Alamofire
 import DropDown

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var rootNV:BaseNV?
  var mainVC:MainVC?
  var navigationService = DMSNavigationService()
    lazy var bundlePath: URL = {
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
        print("\n     DIRECTORY: \(documents.absoluteString)\n")
        let bundlePath = documents.appendingPathComponent("Localize", isDirectory: true)
        return bundlePath
    }()
  
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")//disable autolayout error/warning
    
        let buildConfiguration = BuildConfiguration()
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
    
        // Follow Crashlytics app by Fabric
        Fabric.with([Crashlytics.self])
        DropDown.startListeningToKeyboard()
        SERVICES().socket.delegate = self

        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
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
 
extension AppDelegate:APISocketDelegate{
    func didReceiveConnected(data: Any) {
        guard let user = Caches().user, let userInfo = user.userInfo else { return}
        SERVICES().socket.login(Caches().user?.userInfo?.id ?? 0,
                                E(Caches().user?.userInfo?.userName),
                                E(Caches().user?.roles?.first?.name),
                                E(Caches().user?.token),
                                userInfo)
    }

    func didReceiveError(data: String) {
        if SocketConstants.messangeNeedRelogines.contains(data) {
            App().reLogin()
            self.showAlertView(data)
        }
    }

    func didReceiveResultLogin(data: Any) {
        let mess = getMessengeStatus(data: data).0
        let status = getMessengeStatus(data: data).1
        
        if status != 1 {
            self.showAlertView(E(mess))
            App().reLogin()
        }
    }
    
    func getMessengeStatus(data:Any) -> (String?,Int?) {
        if let dic = (data as? ResponseDictionary){
            let status = dic["status"] as? Int
            let mess = dic["message"] as? String
            return (mess,status)
            
        }else if let dicList = (data as? ResponseArray){
            if let dic = dicList.first as? ResponseDictionary{
                let status = dic["status"] as? Int
                let mess = dic["message"] as? String
                return (mess,status )
            }
        }
        
        return ("Data response is invalid.",-1)
    }
}
