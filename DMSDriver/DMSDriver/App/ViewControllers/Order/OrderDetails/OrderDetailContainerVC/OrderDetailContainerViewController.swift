//
//  OrderDetailContainerViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SVProgressHUD
import ReachabilitySwift

class OrderDetailContainerViewController: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var vInternetConnection:UIView?
    @IBOutlet weak var lblInternetConnection:UILabel?
    @IBOutlet weak var conHeightVInternetConnection:NSLayoutConstraint?
    @IBOutlet weak var conHSegmentedControl: NSLayoutConstraint?
    
    let orderInfoDetailVC:OrderDetailViewController = .loadSB(SB: .Order)
    let orderSignatureVC:OrderSignatureViewController = .loadSB(SB: .Order)
    let orderPicktureVC:OrderPictureViewController = .loadSB(SB:.Order)
    
    let reachability = Reachability()!
    
    var hasConectionNetwork = false
    var route: Route?
    var order:Order?
    var dateStringFilter:String = Date().toString()
    var onUpdateOrderStatus:((_ order: Order) -> Void)?
    
    
    fileprivate var orderDetail: Order?{
        didSet{
            self.orderInfoDetailVC.orderDetail = orderDetail
            self.orderSignatureVC.orderDetail = orderDetail
            self.orderPicktureVC.orderDetail = orderDetail
        }
    }
  
    override func viewDidLoad() {
        settingConfigBarbutton()
        super.viewDidLoad()
        
        if orderDetail == nil {
            orderDetail = order
        }
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNetworkObserver()
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeNetworkObserver()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return setupViewControllerForPagerTab()
    }
    
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex)
        containerView.isScrollEnabled = !((self.orderDetail?.signature == nil) &&
                                        (fromIndex == 1)) // 1 is tap signature
        
    }
    
    //MARK: - NetworkObserver
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
    
    func removeNetworkObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "ReachabilityChangedNotification"),
                                                  object: reachability)
    }
    
    @objc func reachabilityChangedNotification(_ notification: NSNotification) {
        guard let notif = notification.object as? Reachability,
                  notif.isReachable == true else {
                print("No internet connection")
                hasConectionNetwork = false
                queryOrderDetailLocal()
                return
        }
        
        print("has network connection")
        hasConectionNetwork = true
        //getOrderDetail()
        DispatchQueue.main.async {
            App().mainVC?.hideNoInternetConnection()
        }
    }
    
    private func queryOrderDetailLocal()  {
        DispatchQueue.main.async {[weak self] in
            App().mainVC?.showNoInternetConnection()
            guard let _order = self?.order else{
                return
            }
            CoreDataManager.queryOrderDetail(_order.id, callback: {(success,data) in
                self?.orderDetail = data
                self?.updateUI()
                
                for vc in (self?.viewControllers)! {
                    (vc as? BaseOrderDetailViewController)?.orderDetail = self?.orderDetail
                    (vc as? BaseOrderDetailViewController)?.route = self?.route
                }
            })
        }
    }
    
    private func settingConfigBarbutton()  {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = AppColor.mainColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarMinimumInteritemSpacing = 0
        settings.style.buttonBarItemLeftRightMargin = 0

        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = {(oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            //oldCell?.contentView.borderColor = AppColor.grayBorderColor
            //oldCell?.contentView.borderWidth = 0.5
            oldCell?.label.textColor = AppColor.mainColor
            oldCell?.contentView.backgroundColor = AppColor.white
            oldCell?.contentView.layer.cornerRadius = 5

            newCell?.label.textColor = AppColor.white
            newCell?.contentView.backgroundColor = AppColor.mainColor
            newCell?.contentView.layer.cornerRadius = 5
        }
    }
    
    private  func setupViewControllerForPagerTab() -> [UIViewController] {
        orderInfoDetailVC.dateStringFilter = dateStringFilter
        orderInfoDetailVC.orderDetail = order
        orderInfoDetailVC.rootVC = self
        orderInfoDetailVC.didUpdateStatus = { [weak self] (orderDetail, shouldMoveToTab)  in
            self?.onUpdateOrderStatus?(orderDetail)
            self?.orderPicktureVC.updateData(orderDetail)
            self?.orderSignatureVC.updateData(orderDetail)
            
            if shouldMoveToTab != nil {
                self?.moveToViewController(shouldMoveToTab: shouldMoveToTab!)
            }
        }
        
        orderInfoDetailVC.checkConnetionInternet = { [weak self] (notification, hasConnection)  in
            self?.reachabilityChangedNotification(notification)
        }
        
        orderInfoDetailVC.updateOrderDetail = {[weak self] (order) in
            self?.orderDetail = order
        }
        
        orderSignatureVC.orderDetail = order
        orderSignatureVC.rootVC = self
        orderSignatureVC.updateOrderDetail = { [weak self] (order) in
            self?.orderDetail = order
        }
        
        orderPicktureVC.orderDetail = order
        orderPicktureVC.rootVC = self
        orderPicktureVC.updateOrderDetail = { [weak self] (order) in
            self?.orderDetail = order
        }
        
        return [orderInfoDetailVC,orderSignatureVC,orderPicktureVC]
    }
    
    private func moveToViewController(shouldMoveToTab:Int){
        self.reloadPagerTabStripView()
       // self.segmentedControl.selectedSegmentIndex = shouldMoveToTab;
        self.moveToViewController(at: shouldMoveToTab, animated: false)
    }
    
    private func updateUI() {
        containerView.isScrollEnabled = false
    }
    
    private func setupNavigationBar()  {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.BackOnly, "order-detail".localized)
    }
}

extension OrderDetailContainerViewController:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        self.navigationController?.popViewController(animated: true)
    }
}

