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
    
    var isStarting = false
    var isPause = false
    var isCancel = false

    
    
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
        isCancel = true
        isPause = false
        isStarting = false
        Caches().dateStartRoute = nil
        invalidTimmer()
        updateButtonAction()
        resetCountDownTime()
        removePushNotifiactionDrivingRole()
    }
    
    @IBAction func onbtnClickStart(btn:UIButton){
        if isCancel {
            isCancel = false
            isPause = false
            isStarting = true
            Caches().dateStartRoute = Date.now
            startTimer()
            updateTime()
            createPushNotificationDrivingRole()
            
        }else if !isPause {
            isPause = true
            isStarting = false
            isCancel = false
            invalidTimmer()
            
        }else{
            isCancel = false
            isPause = false
            isStarting = true
            
            if Caches().dateStartRoute == nil {
                Caches().dateStartRoute = Date.now
            }

            startTimer()
        }
        
        updateButtonAction()
    }
    
    func removePushNotifiactionDrivingRole()  {
        LocalNotification.removePendingNotifications([NotificationName.remiderTimeoutDrivingRole])
    }
    
    func createPushNotificationDrivingRole() {
        let totalMinutes = drivingRule?.data ?? 0

        LocalNotification.createPushNotificationAfter(totalMinutes,
                                                      "Reminder".localized,
                                                      "Your task has been over.",
                                                      "remider.timeout.drivingrole",  [:])

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
        
        if isStarting || isPause{
            btnCancel?.isEnabled = true
            btnCancel?.alpha = 1
        }else{
            btnCancel?.isEnabled = false
            btnCancel?.alpha = 0.3
        }
        
        if isStarting {
            btnStart?.setStylePauseTimer()
        }else if isPause {
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
        if  timeRemaining?.second ?? 0 <= 0 &&
            timeRemaining?.hour ?? 0 <= 0 &&
            timeRemaining?.minute ?? 0 <= 0 &&
            timeRemaining?.day ?? 0 <= 0 {
            
            isStarting = false
            isPause = false
            isCancel = true
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
        
        let h = timeRemaining?.hour
        let m = timeRemaining?.minute
        let s = timeRemaining?.second
        
        lblTimeRemaining?.text =  "\(h ?? 0) : \(m ?? 0) : \(s ?? 0)"
        isStarting = true
        isCancel = false
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
