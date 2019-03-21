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

class BaseViewController: UIViewController {
  
    private var isRoot = true
    
    let reachability = Reachability()!
    var hasNetworkConnection = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SERVICES().socket.delegate = self
        
        updateUI()
        self.updateNavigationBar()
        addNetworkObserver()
        printControllerName()
    }
    
    deinit {
        removeNetworkObserver()
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
    }
    
    func printControllerName() {
        #if DEBUG
        let name = String(describing: self)
        print("Current Screen is \(name)")
        #endif
    }
    
    
    //MARK: - Reachability
    func addNetworkObserver() {
        // add observer for network reachability
        NotificationCenter.default.addObserver(self,
                    selector: #selector(self.reachabilityChangedNotification(_:)),
                        name: NSNotification.Name(rawValue: "ReachabilityChangedNotification"),
                      object: reachability)
        
        do {
            try reachability.startNotifier()
        }catch let error {
            #if DEBUG
            print("Cannot start notify \(error.localizedDescription)")
            #endif
        }
    }
  
    @objc func reachabilityChangedNotification(_ notification: NSNotification) {
        guard let notif = notification.object as? Reachability, notif.isReachable == true else {
                hasNetworkConnection = false
                print("No internet connection")
                updateUI()
                return
        }
    
        print("has network connection")
        hasNetworkConnection = true
        updateUI()
    }
  
    func removeNetworkObserver() {
        NotificationCenter.default.removeObserver(self,
                    name: NSNotification.Name(rawValue: "ReachabilityChangedNotification"),
                  object: reachability)
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


