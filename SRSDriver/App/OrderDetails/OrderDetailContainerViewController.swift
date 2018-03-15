//
//  OrderDetailContainerViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class OrderDetailContainerViewController: SegmentedPagerTabStripViewController {
  
  override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
    let child_1 = OrderDetailViewController.loadViewController(type: OrderDetailViewController.self)
    let child_2 = OrderSignatureViewController.loadViewController(type: OrderSignatureViewController.self)
    let child_3 = OrderNotesViewController.loadViewController(type: OrderNotesViewController.self)
    let child_4 = OrderPictureViewController.loadViewController(type: OrderPictureViewController.self)
    return [child_1, child_2, child_3, child_4]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

