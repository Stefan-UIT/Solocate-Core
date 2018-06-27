//
//  RouteDetailVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class RouteDetailVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigateBar()
        setupTabBarController()
    }
    
    func setupNavigateBar() {
        let navigationService = DMSNavigationService()
        navigationService.navigationItem = self.navigationItem
        navigationService.updateNavigationBar(.BackOnly, "Route Detail")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTabBarController() {
        
        let orderVC:OrderListViewController = .loadSB(SB: .Order)
        let packageVC:PackagesViewController = .loadSB(SB: .Packages)
        let mapVC:MapsViewController = .loadSB(SB: .Map)
        let messageVC:RouteMessagesViewController = .loadSB(SB: .Message)
        
        orderVC.tabBarItem.title = "Order"
        packageVC.tabBarItem.title = "Packages"
        mapVC.tabBarItem.title = "Map"
        messageVC.tabBarItem.title = "Messages"
        
        orderVC.tabBarItem.image = UIImage.init(named: "list")
        packageVC.tabBarItem.image = UIImage.init(named: "truck-fast")
        mapVC.tabBarItem.image = UIImage.init(named: "map")
        messageVC.tabBarItem.image = UIImage.init(named: "message")

        self.setViewControllers([orderVC,packageVC,mapVC,messageVC], animated: false)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
