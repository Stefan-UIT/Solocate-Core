//
//  OrderListViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import SVProgressHUD

class OrderListViewController: BaseViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var noOrdersLabel: UILabel?
  @IBOutlet weak var datePickerView: UIDatePicker!
  @IBOutlet weak var pickerContainerView: UIView?
  
  fileprivate let cellIdentifier = "OrderItemTableViewCell"
  fileprivate let cellHeight: CGFloat = 150.0
  fileprivate var changePasswordView : ChangePasswordView!
    
  var route: Route?

  fileprivate var leftMenuView : LeftMenuView = LeftMenuView() /* Added by Hoang Trinh */
    
  func getRouteDetail(_ routeID: String) {
    showLoadingIndicator()
    APIs.getRouteDetail(routeID) { [weak self] (response, errMsg) in
      self?.dismissLoadingIndicator()
      guard let route = response, let strongSelf = self else {
        self?.showAlertView(errMsg ?? " ")
        return
      }
      strongSelf.route = route
      strongSelf.tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
 
    updateUI()
    /* Added by Hoang Trinh - Begin */
    leftMenuView.delegate = self
    /* Added by Hoang Trinh - Begin */
  }

  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    /*
    if let route = self.route {
        getRouteDetail("\(route.id)")
    }
    */
    tabBarController?.tabBar.isHidden = false
  }
    
    func updateUI() {
        if let orderList = self.route?.orderList {
            noOrdersLabel?.isHidden = orderList.count > 0
        }
    }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.title = ""// clear title
  }
  
    
  /* Added by Hoang Trinh - Begin */
  @IBAction func tapLeftMenuBarButtonItemAction(_ sender: UIBarButtonItem) {
    if leftMenuView.isDisplayed {
      leftMenuView.hideView()
    } else {
      leftMenuView.showViewInView(superView: self.view, isHiddenStatusBar: false)
    }
  }
}

// MARK: - Private methods

extension OrderListViewController {
  func convertString(_ text: String, withFormat format: String = "yyyy-MM-dd") -> String {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "MM/dd/yyyy"
    let date = dateFormater.date(from: text) ?? Date()
    dateFormater.dateFormat = format
    
    return dateFormater.string(from: date)
    
  }
}

extension OrderListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return route?.orderList.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderItemTableViewCell {
      cell.order = route?.orderList[indexPath.row]
      return cell
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return .none
  }
  
  func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    guard route != nil else { return }
    let movedOrder = route?.orderList[sourceIndexPath.row]
    route?.orderList.remove(at: sourceIndexPath.row)
    route?.orderList.insert(movedOrder!, at: destinationIndexPath.row)
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight.scaleHeight()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    tabBarController?.tabBar.isHidden = true
    
    let vc:OrderDetailContainerViewController = .loadSB(SB: .Order)
    
    if let order = route?.orderList[indexPath.row] {
        vc.orderID = "\(order.id)"
        vc.orderStatus = order.statusCode
        vc.routeID = route?.id
    }
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
}


extension OrderListViewController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    guard  let navigationController = viewController as? UINavigationController else {return}
    if let mapVC = navigationController.topViewController as? MapsViewController {
      mapVC.route = route
    }
    else if let routeMessageVC = navigationController.topViewController as? RouteMessagesViewController {
      routeMessageVC.route = route
    }
    else if let packageVC = navigationController.topViewController as? PackagesViewController {
      packageVC.route = route
    }
  }
}

/* Added by Hoang Trinh - Begin */
extension OrderListViewController : LeftMenuViewDelegate {
    func leftMenuView(_ view: LeftMenuView, _ selectedItem: IdentifierType) {
        view.hideView()
        handleSelectedItemLeftMenu(selectedItem)
    }
    
    func handleSelectedItemLeftMenu(_ type : IdentifierType) {
        switch type {
        case .CHANGE_PASSWORD:
            handleChangePassword()
            break
        case.LOG_OUT:
        handleLogOut()
            break
        case .CHANGE_INVIROMENT:
            handleChangeEnviroment()
            break
        }
    }
    
    func handleChangeEnviroment() {
        DataManager.changeEnviroment()
        handleLogOut()
    }
    
    func handleChangePassword() {
        if (changePasswordView != nil) {
            changePasswordView.resetData()
            changePasswordView.showViewInWindow()
            
        } else {
            changePasswordView = ChangePasswordView()
            changePasswordView.delegate = self
            changePasswordView.showViewInWindow()
        }
    }
    
    func handleLogOut() {
        
        API().logout { (result) in
            switch result{
            case .object(_):
                Caches().user = nil;
            self.navigationController?.navigationController?.popToRootViewController(animated: true)
            case .error(let error):
                self.showAlertView(error.getMessage())
            }
        }
        
        /*
        APIs.logout { [unowned self] (success, msg) in
            if success {
                Cache.setTokenKeyLogin("")
                self.navigationController?.navigationController?.popToRootViewController(animated: true)
            } else {
                print(msg ?? "")
            }
        }
         */
    }
}

extension OrderListViewController : ChangePasswordViewDelegate {
    func changePasswordView(_ view: ChangePasswordView, _ success: Bool, _ errorMessage: String, _ model: ChangePasswordModel?) {
        if success {
            view.removeFromSuperview()
            showAlertView(errorMessage)
        } else {
            if let model = model {
                view.removeFromSuperview()
                if model.oldPassword.count > 0 {
                    showAlertView(model.oldPassword.first!) { (alertAction) in
                        view.showViewInWindow()
                    }
                } else if model.newPassword.count > 0 {
                    showAlertView(model.newPassword.first!) { (alertAction) in
                        view.showViewInWindow()
                    }
                }else if model.rePassword.count > 0 {()
                    showAlertView(model.rePassword.first!) { (alertAction) in
                        view.showViewInWindow()
                    }
                } else {
                    showAlertView(errorMessage) { (alertAction) in
                        view.showViewInWindow()
                    }
                }
            } else {
                view.removeFromSuperview()
                showAlertView(errorMessage) { (alertAction) in
                    view.showViewInWindow()
                }
            }
        }
    }
}
/* Added by Hoang Trinh - End */


