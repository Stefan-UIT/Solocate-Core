//
//  UINavigationController+Ext.swift
//  DMSDriver
//
//  Created by Mach Van  Nguyen on 4/3/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

extension UINavigationController{
    
    func popToController<T: UIViewController>(_ type: T.Type, animated: Bool) {
        if let vc = viewControllers.first(where: { $0 is T }) {
            popToViewController(vc, animated: animated)
        }
    }
    func popToControllerOrToRootControllerIfNotInTheStack<T: UIViewController>(_ type: T.Type, animated: Bool) {
        if let vc = viewControllers.first(where: { $0 is T }) {
            popToViewController(vc, animated: animated)
        } else {
            popToRootViewController(animated: animated)
        }
    }
}
