//
//  RouteDetailVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import Foundation

enum TabBarItem:Int {
    case Order = 0
    case Packages;
    case Map;
    case Messages;
    
    func title() -> String {
        switch self {
        case .Order:
            return "Orders List".localized
        case .Packages:
            return "Packgages".localized
        case .Map :
            return "Map".localized
        case .Messages:
            return "Messanges".localized
        }
    }
}

class RouteDetailVC: UITabBarController {
    
    var route:Route?
    var dateStringFilter:String = Date().toString()
    let kBarHeight = 60
    
    let orderVC:OrderListViewController = .loadSB(SB: .Order)
    let packageVC:PackagesViewController = .loadSB(SB: .Packages)
    let mapVC:MapsViewController = .loadSB(SB: .Map)

    var displayMode:DisplayMode = DisplayMode.Expanded{
        didSet{
            updateNavigationBar()
            reloadOrderListViewController()
        }
    }
    
    var selectedTabBarItem:TabBarItem = .Order{
        didSet{
           updateNavigationBar()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self;
        setupTabBarController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        /*
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = CGFloat(kBarHeight);
        tabFrame.origin.y = self.view.frame.size.height - CGFloat(kBarHeight)
        self.tabBar.frame = tabFrame;
         */
    }
    
    
    func updateNavigationBar()  {
        App().navigationService.delegate = self;
        
        if selectedTabBarItem == .Order {
            App().navigationService.updateNavigationBar(displayMode == .Reduced ? .backCompact : .backModule,
                                                        selectedTabBarItem.title())

        }else{
            App().navigationService.updateNavigationBar(.BackOnly,
                                                        selectedTabBarItem.title())

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadOrderListViewController() {
        orderVC.displayMode = displayMode
    }
    
    func setupTabBarController() {
        self.tabBar.tintColor = AppColor.mainColor
        if let route = self.route {
            orderVC.route = route
            orderVC.dateStringFilter = dateStringFilter
            orderVC.displayMode = displayMode
        }
        if let route = self.route {
            packageVC.route = route
            packageVC.dateStringFilter = dateStringFilter
        }
        if let route = self.route {
            mapVC.route = route
        }

        orderVC.tabBarItem.title = "Orders".localized
        packageVC.tabBarItem.title = "Packages".localized
        mapVC.tabBarItem.title = "Map".localized
        
        orderVC.tabBarItem.image = #imageLiteral(resourceName: "ic_orderlist")
        packageVC.tabBarItem.image = #imageLiteral(resourceName: "ic_car")
        mapVC.tabBarItem.image = #imageLiteral(resourceName: "ic_location")

        orderVC.tabBarItem.tag = 0
        packageVC.tabBarItem.tag = 1
        mapVC.tabBarItem.tag = 2
        
        self.setViewControllers([orderVC,packageVC,mapVC], animated: false)
    }
}

//MARK: UITabBarControllerDelegate
extension RouteDetailVC:UITabBarControllerDelegate{
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let tag = item.tag
        selectedTabBarItem = TabBarItem(rawValue: tag) ?? .Order
    }
    
}


//MARK: - DMSNavigationServiceDelegate
extension RouteDetailVC:DMSNavigationServiceDelegate{
    func didSelectedRightButton() {
        if displayMode == .Reduced {
            displayMode = .Expanded
        }else{
            displayMode = .Reduced
        }
    }
    
    func didSelectedBackOrMenu() {
        self.navigationController?.popViewController(animated: true)
    }
}
