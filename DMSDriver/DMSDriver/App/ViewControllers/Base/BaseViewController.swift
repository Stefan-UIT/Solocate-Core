//
//  BaseViewController.swift
//  truck4less
//
//  Created by phunguyen on 12/22/17.
//  Copyright © 2017 SeldatInc. All rights reserved.
//

import UIKit
import ReachabilitySwift

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
        updateUI()
        self.updateNavigationBar()
        addNetworkObserver()
        printControllerName()
    }
    
    deinit {
        removeNetworkObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
}


