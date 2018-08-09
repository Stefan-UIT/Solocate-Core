//
//  BaseViewController.swift
//  truck4less
//
//  Created by phunguyen on 12/22/17.
//  Copyright © 2017 SeldatInc. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
  @IBOutlet weak var vInternetConnection:UIView?
  @IBOutlet weak var lblInternetConnection:UILabel?
  @IBOutlet weak var conHeightVInternetConnection:NSLayoutConstraint?

  
  private var isRoot = true
    
  var navigationService = DMSNavigationService()
  
  let reachability = Reachability()!
  var hasNetworkConnection = true
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addNetworkObserver()
    
    navigationService.navigationItem = self.navigationItem
    updateNavigationBar()
  }
    
  override var preferredStatusBarStyle: UIStatusBarStyle{
    return UIStatusBarStyle.lightContent
  }
    
  deinit {
    removeNetworkObserver()
  }

  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    printControllerName()
  }
    
  func printControllerName() {
    #if DEBUG
      let name = String(describing: self)
        print("Current Screen is \(name)")
    #endif
  }
  
  func addNetworkObserver() {
    do {
      try reachability.startNotifier()
    }
    catch let error {
        #if DEBUG
            print("Cannot start notify \(error.localizedDescription)")
        #endif
    }
    // add observer for network reachability
    NotificationCenter.default.addObserver(self,
                    selector: #selector(self.reachabilityChangedNotification(_:)),
                        name: NSNotification.Name(rawValue: "ReachabilityChangedNotification"),
                      object: reachability)
  }
  
  @objc func reachabilityChangedNotification(_ notification: NSNotification) {
    guard let notif = notification.object as? Reachability,
        notif.isReachable == true else {
      hasNetworkConnection = false
      print("No internet connection")
      DispatchQueue.main.async {[weak self] in
        self?.showNoInternetConnection()
      }
       return
     }
    
    print("has network connection")
    hasNetworkConnection = true
    DispatchQueue.main.async {[weak self] in
        self?.hideNoInternetConnection()
    }
  }
  
  func showNoInternetConnection() {
    lblInternetConnection?.textColor = .white
    vInternetConnection?.backgroundColor = AppColor.redColor
    lblInternetConnection?.text = "error_lost_network_connection".localized
    lblInternetConnection?.textAlignment = .center
    vInternetConnection?.isHidden = false
    UIView.animate(withDuration: 0.5) {[weak self] in
        self?.conHeightVInternetConnection?.constant = 30
        self?.view.layoutIfNeeded()
    }
  }
  
  func hideNoInternetConnection() {
    self.conHeightVInternetConnection?.constant = 0
    UIView.animate(withDuration: 0.5, animations: {[weak self] in
        self?.vInternetConnection?.isHidden = true
        self?.view.layoutIfNeeded()
        
    }) { (isFinish) in}
  }
  
  func removeNetworkObserver() {
    NotificationCenter.default.removeObserver(self,
                    name: NSNotification.Name(rawValue: "ReachabilityChangedNotification"),
                  object: reachability)
  }
    
    func updateNavigationBar() {
        print("Please update navigation Bar in \(ClassName(self))")
        
    }
    
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


