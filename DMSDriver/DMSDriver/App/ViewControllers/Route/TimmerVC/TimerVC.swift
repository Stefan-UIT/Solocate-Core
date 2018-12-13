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
    var totalTimeRemaining:Int = 0
    var totalSecond = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        drivingRule = Caches().drivingRule
        if drivingRule == nil {
            getDrivingRule()
        }
        
        setupTotalSecondRemaining()
        setupLblTimeRemaining()

        if Caches().isPauseRoute {
            invalidTimmer()
        }else {
            startTimer()
        }
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
        if Caches().isCancelCounter { //Start
            Caches().isCancelCounter = false
            Caches().isPauseRoute = false
            Caches().isStartingRoute = true
            Caches().dateStartRoute = Date.now
            totalSecond = (Caches().drivingRule?.data ?? 0) * 60
            Caches().datePauseRoute = nil
            startTimer()
            updateTime()
            createPushNotificationDrivingRole()
            
        }else if !Caches().isPauseRoute { // Pause
            invalidTimmer()
            removePushNotifiactionDrivingRole()

            Caches().isPauseRoute = true
            Caches().isStartingRoute = false
            Caches().isCancelCounter = false
            Caches().datePauseRoute = Date.now
            let timeBetweenDatePauseAndNow = Caches().datePauseRoute!.offsetFrom(date: Caches().dateStartRoute!, components: [.second])
            let s = timeBetweenDatePauseAndNow.second ?? 0
            Caches().timePlaying = Caches().timePlaying + s
            
        }else{
            Caches().isPauseRoute = false
            Caches().isStartingRoute = true
            Caches().isCancelCounter = false
            
            if Caches().dateStartRoute == nil {
                Caches().dateStartRoute = Date.now
            }
            Caches().dateStartRoute = Date.now
            totalSecond = (self.drivingRule?.data ?? 0) * 60  -  (Caches().timePlaying)
            startTimer()
            createPushNotificationDrivingRole()
        }
        
        updateButtonAction()
    }
    
    func removePushNotifiactionDrivingRole()  {
        LocalNotification.removePendingNotifications([NotificationName.remiderTimeoutDrivingRole])
    }
    
    func createPushNotificationDrivingRole() {
        if totalSecond > 0 {
            LocalNotification.createPushNotificationAfter(totalSecond,
                                                          "Reminder".localized,
                                                          "Your task has been over.",
                                                          "remider.timeout.drivingrole",  [:])
        }
    }
    
    func setupLblTimeRemaining() {
        let hour = Int(totalSecond / 3600)
        let minute = Int((totalSecond - (hour * 3600)) / 60)
        let second = totalSecond - (minute * 60)
        
        updateButtonAction()
        if  hour <= 0 && minute <= 0 && second <= 0{
            invalidTimmer()
            resetCountDownTime()
            return
        }
        
        lblTimeRemaining?.text =  "\(hour) : \(minute) : \(second)"
    }
    
    
    func setupTotalSecondRemaining()  {
        if Caches().isPauseRoute {
            totalSecond = (self.drivingRule?.data ?? 0) * 60  -  (Caches().timePlaying)
            
        }else{
            
            let totalMinutes = drivingRule?.data ?? 0
            var dateStartRoute = Caches().dateStartRoute
            
            let hour = Int(totalMinutes / 60)
            let minute = totalMinutes % 60
            
            var newDate = dateStartRoute
            newDate?.hour = (dateStartRoute?.hour ?? 0) + hour
            newDate?.minute = (dateStartRoute?.minute ?? 0) + minute
            
            let timeRemaining = newDate?.offsetFrom(date: Date.now, components: [.second])
            totalSecond = timeRemaining?.second ?? 0
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
        
        if Caches().isPauseRoute {
            btnStart?.setStyleResumeTimer()
        }else if Caches().isStartingRoute{
            btnStart?.setStylePauseTimer()
        }else{
            btnStart?.setStyleStartTimer()
        }
    }


    @objc func updateTime() {
        totalSecond = totalSecond - 1
        let hour = Int(totalSecond / 3600)
        let minute = Int((totalSecond - (hour * 3600)) / 60)
        let second = totalSecond - (minute * 60)

        if  hour <= 0 && minute <= 0 && second <= 0{
            Caches().isStartingRoute = false
            Caches().isPauseRoute = false
            Caches().isCancelCounter = true
            Caches().timePlaying = 0
            totalSecond = (Caches().drivingRule?.data ?? 0) * 60
            Caches().datePauseRoute = nil
            invalidTimmer()
            updateButtonAction()
            resetCountDownTime()
            return
        }
        lblTimeRemaining?.text =  "\(hour) : \(minute) : \(second)"
        Caches().isStartingRoute = true
        Caches().isCancelCounter = false
        Caches().isPauseRoute = false
        Caches().datePauseRoute = nil
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
