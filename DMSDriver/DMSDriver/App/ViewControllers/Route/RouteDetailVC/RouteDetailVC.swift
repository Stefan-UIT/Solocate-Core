//
//  RouteDetailVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

enum TabBarItem:String {
    case Order = "Orders"
    case Packages = "Packages";
    case Map = "Map";
    case Messages = "Messages";
    
    func titleLocalized() -> String{
        return self.rawValue.localized
    }
}

class RouteDetailVC: UITabBarController {

    let navigationService = DMSNavigationService()
    
    var route:Route?
    var dateStringFilter:String = Date().toString()
    
    var selectedTabBarItem:TabBarItem = .Order{
        didSet{
           updateNavigationBar()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self;
        setupNavigateBar()
        setupTabBarController()
    }
    
    func setupNavigateBar() {
        navigationService.navigationItem = self.navigationItem
        navigationService.delegate = self;
        navigationService.updateNavigationBar(.BackOnly, "Orders List".localized)
    }
    
    func updateNavigationBar()  {
        
        switch selectedTabBarItem {
        case .Order:
            navigationService.updateNavigationBar(.BackOnly, "Orders List".localized)
        case .Packages:
            navigationService.updateNavigationBar(.BackOnly, "Packages".localized)
        case .Map:
            navigationService.updateNavigationBar(.BackOnly, "Map".localized)
        case .Messages:
            navigationService.updateNavigationBar(.BackOnly, "Messanges".localized)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTabBarController() {
        self.tabBar.tintColor = AppColor.mainColor
        let orderVC:OrderListViewController = .loadSB(SB: .Order)
        if let route = self.route {
            orderVC.route = route
        }
        let packageVC:PackagesViewController = .loadSB(SB: .Packages)
        if let route = self.route {
            packageVC.route = route
            packageVC.dateStringFilter = dateStringFilter
        }
        let mapVC:MapsViewController = .loadSB(SB: .Map)
        if let route = self.route {
            mapVC.route = route
        }
        let messageVC:RouteMessagesViewController = .loadSB(SB: .Message)
        if let route = self.route {
            messageVC.route = route
        }
        
        orderVC.tabBarItem.title = "Orders".localized
        packageVC.tabBarItem.title = "Packages".localized
        mapVC.tabBarItem.title = "Map".localized
        messageVC.tabBarItem.title = "Messages".localized
        
        orderVC.tabBarItem.image = #imageLiteral(resourceName: "ic_orderlist")
        packageVC.tabBarItem.image = #imageLiteral(resourceName: "ic_car")
        mapVC.tabBarItem.image = #imageLiteral(resourceName: "ic_location")
        messageVC.tabBarItem.image = #imageLiteral(resourceName: "ic_message")

        self.setViewControllers([orderVC,packageVC,mapVC], animated: false)
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

//MARK: UITabBarControllerDelegate
extension RouteDetailVC:UITabBarControllerDelegate{
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let title = item.title {
            selectedTabBarItem = TabBarItem(rawValue: title) ?? .Order
        }
    }
    
}


//MARK: - DMSNavigationServiceDelegate
extension RouteDetailVC:DMSNavigationServiceDelegate{
    func didSelectedRightButton() {
        //
    }
    
    func didSelectedBackOrMenu() {
        self.navigationController?.popViewController(animated: true)
    }
}
