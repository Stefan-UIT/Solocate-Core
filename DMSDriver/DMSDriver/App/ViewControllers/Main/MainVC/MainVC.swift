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
}
