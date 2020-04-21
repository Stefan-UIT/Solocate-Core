//
//  BaseNV.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import FDFullscreenPopGesture

class BaseNV: UINavigationController {
    
    var statusBarStyle:UIStatusBarStyle = .default

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = AppColor.mainColor
        self.fd_viewControllerBasedNavigationBarAppearanceEnabled  = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension BaseNV:UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
