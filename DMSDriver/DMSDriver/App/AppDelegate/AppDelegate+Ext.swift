//
//  AppDelegate+Ext.swift
//  DMSDriver
//
//  Created by DinhTan on 4/22/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation
import UserNotifications

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
                    task.id = noti.object_data?.object_id ?? 0
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


//MARK: - Essensial funtion
extension AppDelegate {
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
    
    func refreshBadgeIconNumber()  {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = notifications.count
            }
        }
    }
    
    var statusBarView: UIView? {
        return UIApplication.shared.value(forKey: "statusBar") as? UIView
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
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "ok".localized, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        if let viewController = window?.rootViewController {
            viewController.present(alert, animated: true, completion: nil)
        }
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
}
