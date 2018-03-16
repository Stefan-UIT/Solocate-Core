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
  
  override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
    let child_1 = OrderDetailViewController.loadViewController(type: OrderDetailViewController.self)
    let child_2 = OrderSignatureViewController.loadViewController(type: OrderSignatureViewController.self)
    let child_3 = OrderNotesViewController.loadViewController(type: OrderNotesViewController.self)
    let child_4 = OrderPictureViewController.loadViewController(type: OrderPictureViewController.self)
    return [child_1, child_2, child_3, child_4]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Detail"
    if let _orderID = orderID {
      showLoadingIndicator()
      APIs.getOrderDetail(_orderID, completion: { (resp, errorMsg) in
        self.dismissLoadingIndicator()
        guard let orderDetail = resp else {
          self.showAlertView(errorMsg ?? " ")
          return
        }
        
        for v in self.viewControllers {
          (v as? BaseOrderDetailViewController)?.orderDetail = orderDetail
        }        
      })
    }
  }
  
  override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int) {
    super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex)
    containerView.isScrollEnabled = !(toIndex == 1)
  }
  
  
  
}

