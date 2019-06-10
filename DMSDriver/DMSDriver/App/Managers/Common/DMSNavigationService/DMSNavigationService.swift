//
//  DMSNavigationService.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/27/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

@objc protocol DMSNavigationServiceDelegate {
    func didSelectedBackOrMenu()
    @objc optional func didSelectedRightButton()
    @objc optional func didSelectedLeftButton(_ sender:UIBarButtonItem)
    @objc optional func didSelectedAssignButton(_ sender:UIBarButtonItem)
    @objc optional func didSelectedCancelButton(_ sender:UIBarButtonItem)


}

class DMSNavigationService: NSObject , NavigationService {
    
    fileprivate lazy var backBarItem = UIBarButtonItem.back(target: self,
                                                            action: #selector(onNavigationBack(_:)))
    fileprivate lazy var menuBarItem = UIBarButtonItem.menu(target: self,
                                                            action: #selector(onNavigationMenu(_:)))
    fileprivate lazy var compactBarItem = UIBarButtonItem.compact(target: self,
                                                                  action: #selector(onNavigationClickRightButton(_:)))
    fileprivate lazy var moduleBarItem = UIBarButtonItem.module(target: self,
                                                                action: #selector(onNavigationClickRightButton(_:)))
    fileprivate lazy var saveBarItem = UIBarButtonItem.SaveButton(target: self,
                                                                  action: #selector(onNavigationSaveDone(_:)))
    fileprivate lazy var doneBarItem = UIBarButtonItem.doneButton(target: self,
                                                                  action: #selector(onNavigationClickRightButton(_:)))
    fileprivate lazy var selectBarItem = UIBarButtonItem.selectButton(target: self,
                                                                      action: #selector(onNavigationClickRightButton(_:)))
    fileprivate lazy var assignBarItem = UIBarButtonItem.assignButton(target: self,
                                                                      action: #selector(onNavigationSelectAssign(_:)))

    fileprivate lazy var cancelBarItem = UIBarButtonItem.cancelButton(target: self,
                                                                      action: #selector(onNavigationCancel(_:)))
    
    fileprivate lazy var calendarBarItem = UIBarButtonItem.barButtonItem(with: #imageLiteral(resourceName: "ic_calenda"),
                                                                         target: self,
                                                                         action: #selector(onNavigationClickLeftButton(_:)))
    fileprivate lazy var searchBarItem = UIBarButtonItem.barButtonItem(with: #imageLiteral(resourceName: "search-solid"),
                                                                         target: self,
                                                                         action: #selector(onNavigationClickLeftButton(_:)))
    fileprivate lazy var filterBarItem = UIBarButtonItem.filterButton(target: self,
                                                                      action: #selector(onNavigationClickLeftButton(_:)))
    
    
    fileprivate(set) var leftBarButtonItemType: NavigationItemType?
    fileprivate(set) var leftBarButtonAction: NavigationServiceItemAction?
    
    fileprivate(set) var rightBarButtonItemType: NavigationItemType?
    fileprivate(set) var rightBarButtonAction: NavigationServiceItemAction?
    
    var delegate:DMSNavigationServiceDelegate?
    var navigationItem: UINavigationItem?
    var navigationBar: UINavigationBar?
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
        case Menu_Search;
        case Filter_Menu;
        case Menu_Calenda;
        case Menu_Select;
        case Menu_Assign;
        case BackOnly;
        case BackDone;
        case CancelAssign;
        case CancelSave;
        case CancelDone;
        case backCompact;
        case backModule;
    }
    
    func updateNavigationBar(_ barStyle:BarStyle,
                             _ title:String?,
                             _ backgrondBar:UIColor = UIColor.white,
                             _ useLargeTitle:Bool = false) {
        if useLargeTitle == true {
            navigationBar?.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: AppColor.mainColor,
                                                       NSAttributedString.Key.font: Font.helveticaBold(with: 35)]
            navigationItem?.largeTitleDisplayMode = .automatic
            navigationItem?.title = E(title)
            App().statusBarView?.backgroundColor = AppColor.white
        }
        else {
            navigationItem?.largeTitleDisplayMode = .never
            addTitleToNavigationBar(title: E(title) ,color: AppColor.mainColor)
        }
        
        navigationBar?.barTintColor = backgrondBar
        navigationItem?.hidesBackButton = true
        navigationItem?.leftBarButtonItem  = nil
        navigationItem?.rightBarButtonItems  = nil
        switch barStyle {
        case .Menu:
            navigationItem?.rightBarButtonItem  = menuBarItem
            
        case .Menu_Search:
            navigationItem?.rightBarButtonItem  = menuBarItem
            navigationItem?.leftBarButtonItem = searchBarItem
            
        case .Filter_Menu:
            navigationItem?.rightBarButtonItem  = menuBarItem
            navigationItem?.leftBarButtonItem = filterBarItem
            
        case .Menu_Calenda:
            navigationItem?.rightBarButtonItem  = menuBarItem
            navigationItem?.leftBarButtonItem  = calendarBarItem
            
        case .Menu_Select:
            navigationItem?.leftBarButtonItem  = menuBarItem
            navigationItem?.rightBarButtonItem  = selectBarItem
            
        case .Menu_Assign:
            navigationItem?.leftBarButtonItem  = menuBarItem
            navigationItem?.rightBarButtonItem  = assignBarItem

        case .BackOnly:
            navigationItem?.leftBarButtonItem = backBarItem
            break;
            
        case .BackDone:
            navigationItem?.leftBarButtonItem = backBarItem
            navigationItem?.rightBarButtonItem = doneBarItem
            break;
            
        case .CancelAssign:
            navigationItem?.leftBarButtonItem = cancelBarItem
            navigationItem?.rightBarButtonItem = assignBarItem
            
        case .CancelSave:
            navigationItem?.leftBarButtonItem = cancelBarItem
            navigationItem?.rightBarButtonItem = saveBarItem
            
        case .backCompact:
            navigationItem?.leftBarButtonItem = backBarItem
            navigationItem?.rightBarButtonItem  = compactBarItem

         case .backModule:
            navigationItem?.leftBarButtonItem = backBarItem
            navigationItem?.rightBarButtonItem  = moduleBarItem
            
        case .CancelDone:
            break;
        }
    }
    
    @objc func onNavigationBack(_ sender: UIBarButtonItem) {
        delegate?.didSelectedBackOrMenu()
    }
    
    @objc func onNavigationMenu(_ sender: UIBarButtonItem) {
      delegate?.didSelectedBackOrMenu()
    }
    
    @objc func onNavigationClickRightButton(_ sender: UIBarButtonItem) {
        delegate?.didSelectedRightButton!()
    }
    
    @objc func onNavigationClickLeftButton(_ sender: UIBarButtonItem) {
        delegate?.didSelectedLeftButton!(sender)
    }
    
    @objc func onNavigationSaveDone(_ sender: UIBarButtonItem) {
    }
    
    @objc func onNavigationCancel(_ sender: UIBarButtonItem) {
        delegate?.didSelectedCancelButton!(sender)
    }
    
    
    @objc func onNavigationSelectAssign(_ sender: UIBarButtonItem) {
        delegate?.didSelectedAssignButton!(sender)
    }
}
