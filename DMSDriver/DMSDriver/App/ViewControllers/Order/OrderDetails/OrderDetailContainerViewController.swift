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
    var onUpdateOrderStatus:((_ order: OrderDetail) -> Void)?
    
    
    fileprivate var orderDetail: OrderDetail?
  
    override func viewDidLoad() {
        settingConfigBarbutton()
        super.viewDidLoad()
        
        if orderDetail == nil {
            orderDetail = order?.convertToOrderDetail()
        }
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
        containerView.isScrollEnabled = !((self.orderDetail?.url?.sig == nil) &&
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
        getOrderDetail()
        DispatchQueue.main.async {
            App().mainVC?.hideNoInternetConnection()
        }
    }
    
    func queryOrderDetailLocal()  {
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
    
    func settingConfigBarbutton()  {
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
        orderInfoDetailVC.orderDetail = order?.convertToOrderDetail()
        orderInfoDetailVC.didUpdateStatus = { [weak self] (orderDetail, shouldMoveToTab)  in
            self?.getOrderDetail(isFetch: true)
            self?.onUpdateOrderStatus?(orderDetail)
            
            if shouldMoveToTab != nil {
                self?.moveToViewController(shouldMoveToTab: shouldMoveToTab!)
            }
        }
        
        orderInfoDetailVC.checkConnetionInternet = { [weak self] (notification, hasConnection)  in
            self?.reachabilityChangedNotification(notification)
        }
        
        orderInfoDetailVC.updateOrderDetail = { [weak self] in
            self?.getOrderDetail(isFetch: true)
        }
        
        orderSignatureVC.updateOrderDetail = { [weak self] in
            self?.getOrderDetail(isFetch: true)
        }
        
        orderPicktureVC.updateOrderDetail = { [weak self] in
            self?.getOrderDetail(isFetch: true)
        }
        
        return [orderInfoDetailVC,orderSignatureVC,orderPicktureVC]
    }
    
    private func moveToViewController(shouldMoveToTab:Int){
        self.reloadPagerTabStripView()
       // self.segmentedControl.selectedSegmentIndex = shouldMoveToTab;
        self.moveToViewController(at: shouldMoveToTab, animated: false)
    }
    
    private  func updateUI() {
        containerView.isScrollEnabled = false
    }
    
    private func setupNavigationBar()  {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.BackOnly, "Order Detail".localized)
    }
  
    private func getOrderDetail(isFetch:Bool = false) {
        if hasConectionNetwork &&
            ReachabilityManager.isCalling == false {
            guard let _orderID = order?.id else { return }
            if !isFetch {
                showLoadingIndicator()
            }
            API().getOrderDetail(orderId: "\(_orderID)") {[weak self] (result) in
                self?.dismissLoadingIndicator()
                switch result{
                case .object(let object):
                    self?.orderDetail = object
                    self?.updateUI()
                    CoreDataManager.updateOrderDetail(object) // update orderdetail to DB local
                    
                    for vc in self?.viewControllers ?? [] {
                        (vc as? BaseOrderDetailViewController)?.orderDetail = object
                        (vc as? BaseOrderDetailViewController)?.route = self?.route
                    }
                    
                case .error(let error):
                    self?.showAlertView(error.getMessage())
                }
            }
            
        }else {
            //Get data from local DB
            if let _order = self.order{
                CoreDataManager.queryOrderDetail(_order.id, callback: {[weak self] (success,data) in
                    guard let strongSelf = self else{return}
                    strongSelf.orderDetail = data
                    strongSelf.updateUI()
                    for vc in (strongSelf.viewControllers) {
                        (vc as? BaseOrderDetailViewController)?.orderDetail = strongSelf.orderDetail
                        (vc as? BaseOrderDetailViewController)?.route = strongSelf.route
                    }
                })
            }
        }
    }
}

extension OrderDetailContainerViewController:DMSNavigationServiceDelegate{
    
    func didSelectedBackOrMenu() {
        self.navigationController?.popViewController(animated: true)
    }
}

