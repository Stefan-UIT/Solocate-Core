//
//  PopoverDelegate.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 3/5/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class PopoverDelegate: NSObject,UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return .none
    }
}
