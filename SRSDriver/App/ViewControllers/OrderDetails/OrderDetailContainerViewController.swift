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
  var orderID: String?
  var routeID: Int?
  var orderStatus: String?
    
  fileprivate var orderDetail: OrderDetail?
  
  override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
    
    let child_1:OrderDetailViewController = .loadSB(SB: .Order)
    child_1.didUpdateStatus = {
      [weak self] shouldMoveTab  in
      self?.getOrderDetail()
      if shouldMoveTab {
        self?.moveToViewController(at: 1, animated: true) // move to signature tab
      }
    }
    child_1.updateOrderDetail = {
      [weak self] in
      self?.getOrderDetail()
    }
//    let child_2 = OrderSignatureViewController.loadViewController(type: OrderSignatureViewController.self)
//    let child_3 = OrderNotesViewController.loadViewController(type: OrderNotesViewController.self)
    let child_4:OrderPictureViewController = .loadSB(SB:.Order)
    if orderStatus?.compare("DV") == ComparisonResult.orderedSame {
        return [child_1, child_4]
    }
    return [child_1]
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    getOrderDetail()
  }
    
    func setupNavigationBar()  {
        let nv:DMSNavigationService = DMSNavigationService()
        nv.navigationItem = self.navigationItem
        nv.updateNavigationBar(.BackOnly, "order_detail_title".localized)
    }
  
  private func getOrderDetail() {
    guard let _orderID = orderID else { return }
    showLoadingIndicator()
    API().getOrderDetail(orderId: _orderID) {[weak self] (result) in
        self?.dismissLoadingIndicator()
        
        switch result{
        case .object(let object):
            self?.orderDetail = object
            self?.segmentedControl.isUserInteractionEnabled = object.statusCode == "IP" || object.statusCode == "DV"
            self?.containerView.isScrollEnabled = object.statusCode == "IP" || object.statusCode == "DV"
            for v in (self?.viewControllers)! {
                (v as? BaseOrderDetailViewController)?.orderDetail = object
                (v as? BaseOrderDetailViewController)?.routeID = self?.routeID
            }
            
        case .error(let error):
            self?.showAlertView(error.getMessage())
        }
    }
  }
  
  override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int) {
    super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex)
//    guard let _orderDetail = orderDetail else {return}
    containerView.isScrollEnabled = !(toIndex == 1)
  }
}

