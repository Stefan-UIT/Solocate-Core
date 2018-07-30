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

class OrderDetailContainerViewController: SegmentedPagerTabStripViewController {

    
    @IBOutlet weak  var conHSegmentedControl: NSLayoutConstraint?

    
    var routeID: Int?
    var order:Order?
    
    
    var navigateService:DMSNavigationService?
    var onUpdateOrderStatus:((_ order: OrderDetail) -> Void)?
    
    
    fileprivate var orderDetail: OrderDetail?
  
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupNavigationBar()
        getOrderDetail()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        return setupViewControllerForPagerTab()
    }
    
    private  func setupViewControllerForPagerTab() -> [UIViewController] {
        let child_1:OrderDetailViewController = .loadSB(SB: .Order)
        child_1.didUpdateStatus = { [weak self] (orderDetail, shouldMoveTab)  in
            self?.getOrderDetail()
            self?.onUpdateOrderStatus?(orderDetail)

            if shouldMoveTab {
                self?.reloadPagerTabStripView()
                self?.segmentedControl.selectedSegmentIndex = 1;
                self?.moveToViewController(at: 1, animated: false) // move to signature tab
            }
        }
        
        child_1.updateOrderDetail = { [weak self] in
            self?.getOrderDetail()
        }
        
        let child_2:OrderSignatureViewController = .loadSB(SB: .Order)
        child_2.updateOrderDetail = { [weak self] in
            self?.getOrderDetail()
        }
        
        //let child_3 = OrderNotesViewController.loadViewController(type: OrderNotesViewController.self)
        let child_4:OrderPictureViewController = .loadSB(SB:.Order)
        
        if order?.statusCode.compare("DV") == ComparisonResult.orderedSame {
            return [child_1,child_2,child_4]
        }
        return [child_1,child_4]
    }
    
    private  func updateUI() {
        self.segmentedControl.isHidden = !(E(order?.statusCode) == "DV")
        self.conHSegmentedControl?.constant =  E(order?.statusCode) == "DV" ? 60 : 0
        
        containerView.isScrollEnabled = self.orderDetail?.url?.sig != nil
    }
    
    private func setupNavigationBar()  {
        navigateService = DMSNavigationService()
        navigateService?.navigationItem = self.navigationItem
        navigateService?.delegate = self
        navigateService?.updateNavigationBar(.BackOnly, "Order Detail".localized)
    }
  
    private func getOrderDetail() {
        guard let _orderID = order?.id else { return }
        showLoadingIndicator()
        API().getOrderDetail(orderId: "\(_orderID)") {[weak self] (result) in
            self?.dismissLoadingIndicator()
        
            switch result{
            case .object(let object):
                self?.orderDetail = object
                self?.updateUI()
                for vc in (self?.viewControllers)! {
                    (vc as? BaseOrderDetailViewController)?.orderDetail = object
                    (vc as? BaseOrderDetailViewController)?.routeID = self?.routeID
                }
            
            case .error(let error):
                self?.showAlertView(error.getMessage())
        }
    }
  }
    
  
  override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int) {
    super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex)
    
    if let status = order?.status {
        switch status {
        case .deliveryStatus:
            print("From Index: \(fromIndex)")
            containerView.isScrollEnabled = !((self.orderDetail?.url?.sig == nil) &&
                                            (fromIndex == 1)) // 1 is tap signature

        default:
            containerView.isScrollEnabled = true
        }
    }
  }
}

extension OrderDetailContainerViewController:DMSNavigationServiceDelegate{
    
    func didSelectedBackOrMenu() {
        self.navigationController?.popViewController(animated: true)
    }
}

