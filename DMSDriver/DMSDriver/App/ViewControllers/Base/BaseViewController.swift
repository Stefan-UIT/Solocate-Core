//
//  BaseViewController.swift
//  truck4less
//
//  Created by phunguyen on 12/22/17.
//  Copyright © 2017 SeldatInc. All rights reserved.
//

import UIKit
import ReachabilitySwift
import FDFullscreenPopGesture
import SideMenu
import FirebaseAnalytics

class BaseViewController: UIViewController {
  
    private var isRoot = true
    private var obsKeyboardChangeFrame: NSObjectProtocol? = nil;
    
    let reachability = Reachability()!
    var hasNetworkConnection = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.default
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SERVICES().socket.delegate = self
        
        updateUI()
        updateNavigationBar()
        addNetworkObserver()
        printControllerName()
    }
    
    deinit {
        
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            if  ReachabilityManager.isNetworkAvailable {
                App().mainVC?.hideNoInternetConnection()
            }else{
                App().mainVC?.showNoInternetConnection()
            }
        }
    }
    
    func updateNavigationBar() {
        print("Please update navigation Bar in \(ClassName(self))")
        navigationController?.navigationBar.barTintColor = AppColor.white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.borderColor = AppColor.white
    }
    
    func printControllerName() {
        Analytics.setScreenName(ClassName(self), screenClass: ClassName(self))
        #if DEBUG
        let name = String(describing: self)
        print("Current Screen is \(name)")
        #endif
    }
    
    
    //MARK: - Reachability
    func addNetworkObserver() {
        // Available connection to internet
        ReachabilityManager.reachability.whenReachable = {[weak self] reachability in
            print("has network connection")
            self?.reachabilityChangedNetwork(true)
        }
        
        // Lost connection to internet
        ReachabilityManager.reachability.whenUnreachable = {[weak self] reachability in
            print("No internet connection")
            self?.reachabilityChangedNetwork(false)
        }
    }
  
    func reachabilityChangedNetwork(_ isAvailaibleNetwork: Bool) {
        hasNetworkConnection = isAvailaibleNetwork
        updateUI()
    }
    
    
    func keyboardWillChangeFrame(noti: Notification) {}
    
    func showSideMenu()  {
        if Constants.isLeftToRight {
            if let menuRight = SideMenuManager.default.menuRightNavigationController{
                present(menuRight, animated: true, completion: nil)
            }
        }else{
            if let  menuLeft = SideMenuManager.default.menuLeftNavigationController{
                present(menuLeft, animated: true, completion: nil)
            }
        }
    }
}


//MARK: - UIKeyboardWillChangeFrame
extension BaseViewController {
    final func registerForKeyboardNotifications() {
        
        guard obsKeyboardChangeFrame == nil else {
            return;
        }
        
        obsKeyboardChangeFrame =
            NotificationCenter.default.addObserver(forName: .UIKeyboardWillChangeFrame,
                                                   object: nil,
                                                   queue: OperationQueue.main,
                                                   using: keyboardWillChangeFrame(noti:))
    }
    
    final func unregisterForKeyboardNotifications() {
        
        guard let obs = obsKeyboardChangeFrame else {
            return;
        }
        
        obsKeyboardChangeFrame = nil;
        NotificationCenter.default.removeObserver(obs);
    }
    
    @objc func dismissKeyboard(tapGesture: UITapGestureRecognizer?) {
        self.view.endEditing(true);
    }
    
    func getKeyboardHeight(noti:Notification) -> CGFloat {
        
        let userInfo:NSDictionary = noti.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        return keyboardHeight;
    }
    
    func getKeyboardFrameEnd(noti:Notification) -> CGRect {
        
        let userInfo:NSDictionary = noti.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        
        return keyboardRectangle;
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension BaseViewController:UIPopoverPresentationControllerDelegate{
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}


// MARK: - APISocketDelegate
extension BaseViewController:APISocketDelegate{
    func didReceiveConnected(data: Any) {
        SERVICES().socket.login(Caches().user?.userInfo?.id ?? 0,
                                E(Caches().user?.userInfo?.userName),
                                E(Caches().user?.roles?.first?.name),
                                E(Caches().user?.token))
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
}


//MARK: - OtherFuntion
extension BaseViewController{
    
    func onbtnClickBackOrMenu() {
        self.view.endEditing(true)
        if let navi = self.navigationController {
            
            if (navi.viewControllers.count <= 1) {
                if (navi.presentingViewController != nil) {
                    navi.dismiss(animated: true, completion: nil)
                }else{
                    //  Menu Click
                }
            }else {
                navi.popViewController(animated: true);
            }
            
        }else {
            if (self.presentingViewController != nil) {
                self.dismiss(animated: true, completion: nil);
            }
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


