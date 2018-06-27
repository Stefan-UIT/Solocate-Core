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
    title = "order_detail_title".localized
    getOrderDetail()
  }
  
  private func getOrderDetail() {
    guard let _orderID = orderID else { return }
    showLoadingIndicator()
    APIs.getOrderDetail(_orderID, completion: { [unowned self] (resp,error,errorMsg) in
      self.dismissLoadingIndicator()
      guard let orderDetail = resp else {
        if let error = error {
            if error.statusCode == 401 {
                self.showAlertView(errorMsg ?? " ", completionHandler: { [unowned self] (action) in
                    self.navigationController?.popViewController(animated: true)
                })
                return
            }
        }
        self.showAlertView(errorMsg ?? " ")
        return
      }
      if orderDetail.id < 0 {
        Cache.shared.setObject(obj: "", forKey: Defaultkey.tokenKey)
        self.showAlertView("error_network".localized, completionHandler: { [unowned self] (action) in
          self.navigationController?.navigationController?.popViewController(animated: true)
        })
        return
      }
      self.orderDetail = orderDetail
      self.segmentedControl.isUserInteractionEnabled = orderDetail.statusCode == "IP" || orderDetail.statusCode == "DV"
      self.containerView.isScrollEnabled = orderDetail.statusCode == "IP" || orderDetail.statusCode == "DV"
      for v in self.viewControllers {
        (v as? BaseOrderDetailViewController)?.orderDetail = orderDetail
        (v as? BaseOrderDetailViewController)?.routeID = self.routeID
      }
    })
  }
  
  override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int) {
    super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex)
//    guard let _orderDetail = orderDetail else {return}
    containerView.isScrollEnabled = !(toIndex == 1)
  }
}

