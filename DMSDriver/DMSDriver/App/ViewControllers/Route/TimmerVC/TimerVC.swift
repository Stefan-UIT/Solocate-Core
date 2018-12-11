//
//  TimerVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 11/27/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import SideMenu

class TimerVC: BaseViewController {
    
    @IBOutlet weak var lblTimeRemaining:UILabel?
    @IBOutlet weak var btnCancel:UIButton?
    @IBOutlet weak var btnStart:UIButton?
    
    
    var timmerTime:Timer?
    var route:Route?
    var drivingRule:DrivingRule?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //test
        if Caches().dateStartRoute == nil {
            Caches().dateStartRoute = Date.now
        }
        
        drivingRule = Caches().drivingRule
        if drivingRule == nil {
            getDrivingRule()
        }
        updateTime()
        startTimer()
        updateButtonAction()
    }
    
    
    override func updateNavigationBar() {
        setupNavigateBar()
    }
    
    func setupNavigateBar() {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Menu, "Counter".localized)
    }
    
    
    //MARK: - ACTION
    @IBAction func onbtnClickCancel(btn:UIButton){
        Caches().isCancelCounter = true
        Caches().isPauseRoute = false
        Caches().isStartingRoute = false
        Caches().dateStartRoute = nil
        invalidTimmer()
        updateButtonAction()
        resetCountDownTime()
        removePushNotifiactionDrivingRole()
    }
    
    @IBAction func onbtnClickStart(btn:UIButton){
        if Caches().isCancelCounter {
            Caches().isCancelCounter = false
            Caches().isPauseRoute = false
            Caches().isStartingRoute = true
            Caches().dateStartRoute = Date.now
            Caches().timeRemaining = (drivingRule?.data ?? 0 ) * 60 //second
            startTimer()
            updateTime()
            createPushNotificationDrivingRole()
            
        }else if !Caches().isPauseRoute {
            Caches().isPauseRoute = true
            Caches().isStartingRoute = false
            Caches().isCancelCounter = false
            invalidTimmer()
            removePushNotifiactionDrivingRole()
            
        }else{
            Caches().isPauseRoute = false
            Caches().isStartingRoute = true
            Caches().isCancelCounter = false
            
            if Caches().dateStartRoute == nil {
                Caches().dateStartRoute = Date.now
            }

            startTimer()
            createPushNotificationDrivingRole()
        }
        
        updateButtonAction()
    }
    
    func removePushNotifiactionDrivingRole()  {
        LocalNotification.removePendingNotifications([NotificationName.remiderTimeoutDrivingRole])
    }
    
    func createPushNotificationDrivingRole() {
        if Caches().timeRemaining > 0 {
            LocalNotification.createPushNotificationAfter(Caches().timeRemaining,
                                                          "Reminder".localized,
                                                          "Your task has been over.",
                                                          "remider.timeout.drivingrole",  [:])
        }
    }
}


//MARK: - DMSNavigationServiceDelegate
extension TimerVC:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        if Constants.isLeftToRight {
            if let  menuLeft = SideMenuManager.default.menuLeftNavigationController{
                present(menuLeft, animated: true, completion: nil)
            }
        }else{
            if let menuRight = SideMenuManager.default.menuRightNavigationController{
                present(menuRight, animated: true, completion: nil)
            }
        }
    }
}


//MARK: - API
fileprivate extension TimerVC{
    func getDrivingRule()  {
        self.showLoadingIndicator()
        SERVICES().API.getDrivingRule {[weak self] (result) in
            guard let strongSelf = self else {return}
            strongSelf.dismissLoadingIndicator()
            switch result{
            case .object(let obj):
                strongSelf.drivingRule = obj
                strongSelf.startTimer()
                
            case .error(let error):
                strongSelf.showAlertView(error.getMessage())
            }
        }
    }
}

// MARK: - OTHER FUNTIONS
fileprivate extension TimerVC{
    func resetCountDownTime()  {
        let totalMinutes = drivingRule?.data ?? 0
        let hour = Int(totalMinutes / 60)
        let minute = totalMinutes % 60
        lblTimeRemaining?.text = "\(hour) : \(minute) : 0"
    }
    
    func updateButtonAction()  {
        btnCancel?.setStyleCancelTimer()
        
        if Caches().isStartingRoute || Caches().isPauseRoute{
            btnCancel?.isEnabled = true
            btnCancel?.alpha = 1
        }else{
            btnCancel?.isEnabled = false
            btnCancel?.alpha = 0.3
        }
        
        if Caches().isStartingRoute {
            btnStart?.setStylePauseTimer()
        }else if Caches().isPauseRoute {
            btnStart?.setStyleResumeTimer()
        }else {
            btnStart?.setStyleStartTimer()
        }
    }
    
    
    @objc func updateTime() {
        
        let totalMinutes = drivingRule?.data ?? 0
        var dateStartRoute = Caches().dateStartRoute
        
        let hour = Int(totalMinutes / 60)
        let minute = totalMinutes % 60
        
        var newDate = dateStartRoute
        newDate?.hour = (dateStartRoute?.hour ?? 0) + hour
        newDate?.minute = (dateStartRoute?.minute ?? 0) + minute
        
        let timeRemaining = newDate?.offsetFrom(date: Date.now)
        let h = timeRemaining?.hour ?? 0
        let m = timeRemaining?.minute ?? 0
        let s = timeRemaining?.second ?? 0
        
        if  timeRemaining?.second ?? 0 <= 0 &&
            timeRemaining?.hour ?? 0 <= 0 &&
            timeRemaining?.minute ?? 0 <= 0 &&
            timeRemaining?.day ?? 0 <= 0 {
            
            Caches().isStartingRoute = false
            Caches().isPauseRoute = false
            Caches().isCancelCounter = true
            Caches().timeRemaining = 0
            invalidTimmer()
            updateButtonAction()
            resetCountDownTime()
            
            /*
            if route?.checkInprogess() == true {
                LocalNotification.createPushNotification(Date.now,
                                                         "Reminder".localized,
                                                         "You have finished working shifts",
                                                         [:])
            }
             */
            return
        }
        
        Caches().timeRemaining = (h * 60 * 60) + (m * 60) + s
        lblTimeRemaining?.text =  "\(h) : \(m) : \(s)"
        Caches().isStartingRoute = true
        Caches().isCancelCounter = false
    }
    
    
    func startTimer()  {
        invalidTimmer()
        timmerTime = Timer.scheduledTimer(timeInterval: 1,
                                          target: self,
                                          selector: #selector(updateTime),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    func invalidTimmer()  {
        timmerTime?.invalidate()
        timmerTime = nil
    }
}
