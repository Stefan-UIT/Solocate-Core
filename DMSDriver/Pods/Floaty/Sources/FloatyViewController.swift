//
//  FloatyViewController.swift
//
//  Created by LeeSunhyoup on 2015. 10. 13..
//  Copyright © 2015년 kciter. All rights reserved.
//

import UIKit

/**
 KCFloatingActionButton dependent on UIWindow.
 */
open class FloatyViewController: UIViewController {
  public let floaty = Floaty()
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(floaty)
  }
  
  override open var preferredStatusBarStyle: UIStatusBarStyle {
    get {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
  }
}
