//
//  BaseViewController.swift
//  truck4less
//
//  Created by phunguyen on 12/22/17.
//  Copyright © 2017 SeldatInc. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
  
  private var isRoot = true
  
  let reachability = Reachability()!
  var hasNetworkConnection = true
    
  override func viewDidLoad() {
    super.viewDidLoad()
    let noInternetLabel = UILabel(frame: CGRect(x: 0, y: 64.0, width: view.frame.width, height: 30.0))
    noInternetLabel.textColor = .white
    noInternetLabel.backgroundColor = UIColor(hex: "#383B43")
    noInternetLabel.text = "error_lost_network_connection".localized
    noInternetLabel.textAlignment = .center
    noInternetLabel.tag = 10001
    noInternetLabel.isHidden = true
    view.insertSubview(noInternetLabel, at: 10001)
  }

  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  func addNetworkObserver() {
    do {
      try reachability.startNotifier()
    }
    catch let error {
      print("Cannot start notify \(error.localizedDescription)")
    }
    // add observer for network reachability
    NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChangedNotification(_:)), name: NSNotification.Name(rawValue: "ReachabilityChangedNotification"), object: reachability)
  }
  
  @objc func reachabilityChangedNotification(_ notification: NSNotification) {
    guard let notif = notification.object as? Reachability, notif.isReachable == true else {
      hasNetworkConnection = false
      print("No internet connection")
      showNoInternetConnection()
      return
    }
    print("has network connection")
    hasNetworkConnection = true
    hideNoInternetConnection()
  }
  
  func showNoInternetConnection() {
    if let label = view.viewWithTag(10001) {
      label.isHidden = false
    }
  }
  
  func hideNoInternetConnection() {
    if let label = view.viewWithTag(10001) {
        label.isHidden = true
    }
  }
  
  func removeNetworkObserver() {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReachabilityChangedNotification"), object: reachability)
  }
  
  
  
}

extension UIViewController {
  class func loadViewController<T: UIViewController>(type: T.Type) -> T {
    let className = String.className(aClass: type)
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    return mainStoryboard.instantiateViewController(withIdentifier: className) as! T
  }
}

