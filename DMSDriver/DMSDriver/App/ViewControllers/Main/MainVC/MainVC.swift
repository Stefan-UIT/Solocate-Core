//
//  MainVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import SideMenu

class MainVC: BaseViewController {

    @IBOutlet weak var vInternetConnection:UIView?
    @IBOutlet weak var lblInternetConnection:UILabel?
    @IBOutlet weak var conHeightVInternetConnection:NSLayoutConstraint?
    
    var rootNV:BaseNV?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSideMenu()
        pushRouteListVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Main_NV" {
            rootNV = segue.destination as? BaseNV
        }
    }
  
    func setupSideMenu() {
      
      let slideMenu: SlideMenuVC = .loadSB(SB: .Main)
      
      let slideMenuNC = UISideMenuNavigationController(rootViewController: slideMenu)
      
      slideMenuNC.navigationBar.isHidden = true
      SideMenuManager.default.menuPresentMode = .viewSlideOut
      SideMenuManager.default.menuFadeStatusBar = false
      SideMenuManager.default.menuAnimationTransformScaleFactor = 0.95
        
        if Constants.isLeftToRight {
            SideMenuManager.default.menuLeftNavigationController = slideMenuNC
        }else {
            SideMenuManager.default.menuRightNavigationController = slideMenuNC
        }
      
    }
    
    func pushRouteListVC() {
        let vc:RouteListVC = .loadSB(SB: .Route)
        rootNV?.setViewControllers([vc], animated: false)
    }
    
    func refetchDataRouteOrTaskList()  {
        rootNV?.viewControllers.forEach({ (viewController) in
            if ((viewController as? RouteListVC) != nil) {
                (viewController as? RouteListVC)?.fetchData()
                return
            }else if (((viewController as? TaskListVC) != nil)){
                (viewController as? TaskListVC)?.getListTask(isFetch: true)
                return

            }
        })
    }
    
    func endAutoRefetchRouteList() {
        rootNV?.viewControllers.forEach({ (viewController) in
            if ((viewController as? RouteListVC) != nil) {
                (viewController as? RouteListVC)?.endAutoRefetchRouteList()
                return
            }
        })
    }
    
    
    //MARK: - NoInternetConnection(
    func showNoInternetConnection() {
        lblInternetConnection?.textColor = .white
        vInternetConnection?.backgroundColor = AppColor.mainColor
        vInternetConnection?.setShadowDefault()
        lblInternetConnection?.text = "You are in offline,some funtion may be restricted.".localized
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
}
