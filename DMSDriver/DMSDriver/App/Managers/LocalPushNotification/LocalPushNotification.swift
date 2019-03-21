//
//  LocalPushNotification.swift
//  VSip-iOS
//
//  Created by machnguyen_uit on 8/7/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications

let LocalNotification = LocalPushNotification.shareIntance

class LocalPushNotification: NSObject {
    
    static let shareIntance = LocalPushNotification()
    
    func createPushNotificationAfter(_ second: Int,
                                     _ title:String,
                                     _ descr:String,
                                     _ identifier:String,
                                     _ userInfo:ResponseDictionary) {
        if #available(iOS 10.0, *) {
            //iOS 10 or above version
            let center =  UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = descr
            
            content.userInfo = ["data": userInfo]
            content.sound = UNNotificationSound.default()
            
            
            /*
             //Calendar
             let date = Date(timeIntervalSinceNow: 1)
             let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
             
             let trigger2 = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
             
             */
            
            //Time interval
            let trigger1 = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(second), repeats: false)
            let request = UNNotificationRequest(identifier:identifier,
                content: content,
                trigger: trigger1)
            center.add(request)
            
        } else {
            // ios 9
            /*
             let notification = UILocalNotification()
             notification.fireDate = NSDate(timeIntervalSinceNow: 5) as Date
             notification.alertTitle = E(notiModel.title)
             notification.alertBody = E(notiModel.descr)
             notification.alertAction = "be awesome!"
             notification.soundName = UILocalNotificationDefaultSoundName
             UIApplication.shared.scheduleLocalNotification(notification)
             */
        }
    }
    
    func createPushNotification(_ date:Date,
                                _ title:String,
                                _ descr:String,
                                _ identifier:String? = nil,
                                _ userInfo:ResponseDictionary) {
        if #available(iOS 10.0, *) {
            //iOS 10 or above version
            let center =  UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = descr
            content.userInfo = ["data": userInfo]
            content.sound = UNNotificationSound.default()
             //Calendar
             let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
             let trigger2 = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
             let iden = identifier ?? "\(ServerDateFormater.string(from: date))"
             let request = UNNotificationRequest(identifier:iden,
                content: content,
                trigger: trigger2)
            
            center.add(request)
            
        } else {
            // ios 9
            let notification = UILocalNotification()
            notification.fireDate = NSDate(timeIntervalSinceNow: 5) as Date
            notification.alertTitle = title
            notification.alertBody = descr
            notification.alertAction = "be awesome!"
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    func removePendingNotifications(_ identifiers:[String]) {
        
        let center =  UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
