//
//  DMSNavigationService.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/27/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

protocol DMSNavigationServiceDelegate {
    func didSelectedBackOrMenu()
    func didSelectedRightButton()

}

class DMSNavigationService: NSObject , NavigationService {
    
    fileprivate lazy var backBarItem : UIBarButtonItem = UIBarButtonItem.back(target: self,
                                                                              action: #selector(onNavigationBack(_:)))
    fileprivate lazy var menuBarItem : UIBarButtonItem = UIBarButtonItem.menu(target: self,
                                                                              action: #selector(onNavigationMenu(_:)))
    fileprivate lazy var saveBarItem : UIBarButtonItem = UIBarButtonItem.SaveButton(target: self,
                                                                                    action: #selector(onNavigationSaveDone(_:)))
    fileprivate lazy var doneBarItem : UIBarButtonItem = UIBarButtonItem.doneButton(target: self,
                                                                                    action: #selector(onNavigationSaveDone(_:)))
    fileprivate lazy var cancelBarItem : UIBarButtonItem = UIBarButtonItem.cancelButton(target: self,
                                                                                        action: #selector(onNavigationBack(_:)))
    fileprivate lazy var calendarBarItem = UIBarButtonItem.barButtonItem(with: UIImage(named: "calendarWhite")!,
                                                                         target: self,
                                                                         action: #selector(onNavigationClickRightButton(_:)))
    
    
    fileprivate(set) var leftBarButtonItemType: NavigationItemType?
    fileprivate(set) var leftBarButtonAction: NavigationServiceItemAction?
    
    fileprivate(set) var rightBarButtonItemType: NavigationItemType?
    fileprivate(set) var rightBarButtonAction: NavigationServiceItemAction?
    
    var delegate:DMSNavigationServiceDelegate?
    var navigationItem: UINavigationItem?
    var defaultTitle: String?
    var shouldShowOrderTrackingIndicator: Bool = false
    
    required override init() {
    }
    
    func setUp(leftBarButtonItemType: NavigationItemType?,
               leftBarButtonAction: NavigationServiceItemAction?) {
        self.leftBarButtonItemType = leftBarButtonItemType
        self.leftBarButtonAction = leftBarButtonAction
    }
    
    func setUp(rightBarButtonItemType: NavigationItemType?,
               rightBarButtonAction: NavigationServiceItemAction?) {
        self.rightBarButtonItemType = rightBarButtonItemType
        self.rightBarButtonAction = rightBarButtonAction
    }
    
    func start() {
        updateNavigationItem()
    }
    
    func setUpStandardNavigationItem(forViewController viewController: UIViewController) {
        
        navigationItem?.backBarButtonItem = barButtonItem(for: .back, target: self, action: #selector(didTapBackBarButtonItem));
        
        setUp(rightBarButtonItemType: .close, rightBarButtonAction: { [weak viewController] in
            guard let theViewController = viewController else { return }
            
            theViewController.dismiss(animated: true, completion: nil);
        })
        
        start()
    }
    
    @objc func didTapBackBarButtonItem() {
        leftBarButtonAction?()
    }
    
    @objc func didTapLeftBarButtonItem() {
        leftBarButtonAction?()
    }
    
    @objc func didTapRightBarButtonItem() {
        rightBarButtonAction?()
    }
    
    func performAnimationAction(for itemType: NavigationItemType) {
    }
}

fileprivate extension DMSNavigationService {
    
    
    func updateNavigationItem() {
        guard let navigationItem = navigationItem else {
            assertionFailure("The navigationItem property must be set before this method is called.")
            
            return
        }
        
        navigationItem.leftBarButtonItem = barButtonItem(for: leftBarButtonItemType, target: self, action: #selector(didTapLeftBarButtonItem))
        setUpRightBarButtonItem()
    }
    
    func setUpRightBarButtonItem() {
        let rightBarButtonItem = barButtonItem(for: rightBarButtonItemType, target: self, action: #selector(didTapRightBarButtonItem))
        
        if let rightBarButtonItem = rightBarButtonItem {
            navigationItem?.rightBarButtonItems = [rightBarButtonItem]
        } else {
            navigationItem?.rightBarButtonItems = nil
        }
    }
    
    func addTitleToNavigationBar(title: String, color:UIColor? = AppColor.white) {
        let label = UILabel()
        
        label.textColor = color
        //label.font = Font.helveticaRegular(with: 17)
        label.text = title
        label.sizeToFit()
        
        navigationItem?.titleView = label
    }
}

extension DMSNavigationService {
    enum BarStyle {
        case Menu;
        case Menu_Calenda;
        case BackOnly;
        case BackDone;
        case CancelSave;
        case CanCelDone;
    }
    
    func updateNavigationBar(_ barStyle:BarStyle, _ title:String?) {
        
        if let title = title {
            self.addTitleToNavigationBar(title: title)
        }
        switch barStyle {
        case .Menu:
            navigationItem?.leftBarButtonItem  = menuBarItem
            break;
        case .Menu_Calenda:
            navigationItem?.leftBarButtonItem  = menuBarItem
            navigationItem?.rightBarButtonItem  = calendarBarItem
            
            break;
        case .BackOnly:
            navigationItem?.leftBarButtonItem = backBarItem
            break;
        case .BackDone:
            navigationItem?.leftBarButtonItem = backBarItem
            navigationItem?.rightBarButtonItem = doneBarItem
            break;
        case .CancelSave:
            navigationItem?.leftBarButtonItem = cancelBarItem
            navigationItem?.rightBarButtonItem = saveBarItem
            
            break;
        case .CanCelDone:
            break;
        }
    }
    
    @objc func onNavigationBack(_ sender: UIBarButtonItem) {
        delegate?.didSelectedBackOrMenu()
    }
    
    @objc func onNavigationMenu(_ sender: UIBarButtonItem) {
        // App().mainVC?.showSlideMenu(isShow: true, animation: true)
    }
    
    @objc func onNavigationClickRightButton(_ sender: UIBarButtonItem) {
        delegate?.didSelectedRightButton()
    }
    
    @objc func onNavigationSaveDone(_ sender: UIBarButtonItem) {
    }
}
