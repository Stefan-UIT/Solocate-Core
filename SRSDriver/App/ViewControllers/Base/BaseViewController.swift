//
//  BaseViewController.swift
//  truck4less
//
//  Created by phunguyen on 12/22/17.
//  Copyright © 2017 SeldatInc. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    fileprivate lazy var backBarItem : UIBarButtonItem = UIBarButtonItem.back(target: self, action: #selector(onNavigationBack(_:)))
    fileprivate lazy var menuBarItem : UIBarButtonItem = UIBarButtonItem.menu(target: self, action: #selector(onNavigationMenu(_:)))
    fileprivate lazy var saveBarItem : UIBarButtonItem = UIBarButtonItem.SaveButton(target: self, action: #selector(onNavigationSaveDone(_:)))
    fileprivate lazy var doneBarItem : UIBarButtonItem = UIBarButtonItem.doneButton(target: self, action: #selector(onNavigationSaveDone(_:)))
    fileprivate lazy var cancelBarItem : UIBarButtonItem = UIBarButtonItem.cancelButton(target: self, action: #selector(onNavigationBack(_:)))
  
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
    addNetworkObserver()
  }
  deinit {
    removeNetworkObserver()
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


enum BarStyle {
    case Menu;
    case BackOnly;
    case BackDone;
    case CancelSave;
    case CanCelDone;
}


// MARK: - Navigation
extension BaseViewController {
    func updateNavigationBar(_ barStyle:BarStyle, _ title:String?) {
        
        if let title = title {
            self.addTitleToNavigationBar(title: title)
        }
        switch barStyle {
        case .Menu:
            self.navigationItem.leftBarButtonItem = menuBarItem
            break;
        case .BackOnly:
            self.navigationItem.leftBarButtonItem = backBarItem
            break;
        case .BackDone:
            self.navigationItem.leftBarButtonItem = backBarItem
            self.navigationItem.rightBarButtonItem = doneBarItem
            break;
        case .CancelSave:
            self.navigationItem.leftBarButtonItem = cancelBarItem
            self.navigationItem.rightBarButtonItem = saveBarItem
            
            break;
        case .CanCelDone:
            break;
        }
    }
    
    @objc func onNavigationBack(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        
        if let navi = self.navigationController {
            
            if (navi.viewControllers.count <= 1) {
                if (navi.presentingViewController != nil) {
                    navi.dismiss(animated: true, completion: nil)
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
    
    @objc func onNavigationMenu(_ sender: UIBarButtonItem) {
       // App().mainVC?.showSlideMenu(isShow: true, animation: true)
    }
    
    @objc func onNavigationSaveDone(_ sender: UIBarButtonItem) {
    }
    
}

