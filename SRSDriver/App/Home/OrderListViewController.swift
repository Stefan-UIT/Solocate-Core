//
//  OrderListViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import SVProgressHUD

class OrderListViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var noOrdersLabel: UILabel!
  @IBOutlet weak var datePickerView: UIDatePicker!
  @IBOutlet weak var pickerContainerView: UIView!
  
  fileprivate let cellIdentifier = "OrderItemTableViewCell"
  fileprivate let cellHeight: CGFloat = 150.0
  fileprivate var selectedString = "" {
    didSet {
      navigationItem.title = selectedString
    }
  }
  fileprivate var route: Route! {
    didSet {
      guard let tabItems = self.tabBarController?.tabBar.items else { return }
      if let messageTab = tabItems.last {
        messageTab.badgeValue = nil
      }
      if Constants.packageTabIndex < tabItems.count {
        let packageTab = tabItems[Constants.packageTabIndex]
        packageTab.badgeValue = nil
      }
      
      guard route.orderList.count > 0 else {
        noOrdersLabel.isHidden = false
        tableView.isHidden = true
        navigationItem.rightBarButtonItem?.isEnabled = false
        return
      }
      noOrdersLabel.isHidden = true
      tableView.isHidden = false
      navigationItem.rightBarButtonItem?.isEnabled = route.status != "DV" && route.orderList.count > 1
      tableView.reloadData()
      
      // messgae
      if let messageTab = tabItems.last {
        messageTab.badgeValue = route.messages.count > 0 ? "\(route.messages.count)" : nil
      }
      let packageTab = tabItems[Constants.packageTabIndex]
      packageTab.badgeValue = route.currentItems.count > 0 ? "\(route.currentItems.count)" : nil
      
      guard let viewControllers = tabBarController?.viewControllers else {return}
      
      if let messageNV = viewControllers.last as? UINavigationController,
        let messageVC = messageNV.topViewController as? RouteMessagesViewController {
        messageVC.route = route        
      }
      if Constants.packageTabIndex < viewControllers.count {
        let packageNavC = viewControllers[Constants.packageTabIndex] as? UINavigationController
        if let package = packageNavC?.topViewController as? PackagesViewController {
          package.route = route
        }
      }
    }
  }
  
  func getRouteDetail(_ routeID: String) {
    showLoadingIndicator()
    APIs.getRouteDetail(routeID) { [weak self] (response, errMsg) in
      self?.dismissLoadingIndicator()
      guard let route = response, let strongSelf = self else {
        self?.showAlertView(errMsg ?? " ")
        return
      }
      strongSelf.route = route
      strongSelf.selectedString = strongSelf.convertString(route.date)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    selectedString = datePickerView.date.toString("yyyy-MM-dd")
    tabBarController?.delegate = self
    let iconName = Constants.isLeftToRight ? "logout" : "logout_inv"
    if let leftButton = navigationItem.leftBarButtonItems?.first {
      leftButton.image = UIImage(named: iconName)
    }
    
    // Update fcm token
    if let fcmtoken = Cache.shared.getObject(forKey: Defaultkey.fcmToken) as? String {
      APIs.updateNotificationToken(fcmtoken)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.title = selectedString
    getOrders(byDate: selectedString)
    tabBarController?.tabBar.isHidden = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.title = ""// clear title
  }
  
  @IBAction func didPickDate(_ sender: UIDatePicker) {
    selectedString = sender.date.toString()
  }
  
  @IBAction func didChooseCalendar(_ sender: UIBarButtonItem) {
    let dateString = datePickerView.date.toString("yyyy-MM-dd")
    selectedString = dateString
    getOrders(byDate: dateString)
    noOrdersLabel.isHidden = true
    let height = Constants.toolbarHeight + Constants.pickerViewHeight;
    pickerContainerView.transform = CGAffineTransform(translationX: 0, y: -height)
    UIView.animate(withDuration: 0.25, animations: {
      self.pickerContainerView.transform = CGAffineTransform(translationX: 0, y: -height)
    }) { (isFinish) in
      self.pickerContainerView.isHidden = true
      self.pickerContainerView.transform = .identity
    }
  }
  
  @IBAction func editMode(_ sender: UIBarButtonItem) {
    tableView.isEditing = !tableView.isEditing
    sender.title = tableView.isEditing ? "done".localized : "edit".localized
    guard !tableView.isEditing else {
      return
    }
    //    
    let orderIDs = route.orderList.map { "\($0.id)" }
    showLoadingIndicator()
    APIs.updateRouteSequenceOrders("\(route.id)", routeStatus: route.status, orderIDs: orderIDs) { [unowned self] (msgError) in
      self.dismissLoadingIndicator()
      if let msg = msgError {
        self.showAlertView(msg)
      }
      else {
        self.getOrders(byDate: self.datePickerView.date.toString("yyyy-MM-dd"))
      }
      
    }
  }
  
  @IBAction func logout(_ sender: UIBarButtonItem) {
    Cache.shared.setObject(obj: "", forKey: Defaultkey.tokenKey)
    APIs.updateNotificationToken("")
    navigationController?.navigationController?.popToRootViewController(animated: true)
  }
  
  @IBAction func showCalendar(_ sender: UIBarButtonItem) {
    pickerContainerView.isHidden = false
    let height = Constants.toolbarHeight + Constants.pickerViewHeight;
    pickerContainerView.transform = CGAffineTransform(translationX: 0, y: height)
    UIView.animate(withDuration: 0.25) {
      self.pickerContainerView.transform = .identity
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == SegueIdentifier.showOrderDetail,
      let destVC = segue.destination as? OrderDetailContainerViewController,
      let order = sender as? Order {
      destVC.orderID = "\(order.id)"
      destVC.routeID = route.id
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
  
  func getOrders(byDate date: String? = nil) {
    navigationItem.rightBarButtonItem?.isEnabled = true
    showLoadingIndicator()
    APIs.getOrders(byDate: date) { [unowned self] (resp, msg) in
      self.dismissLoadingIndicator()
      guard let route = resp else {
        self.showAlertView(msg ?? " ")
        return
      }
      self.route = route
    }
  }
}

extension OrderListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if route == nil {
      return 0
    }
    return route.orderList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderItemTableViewCell {
      cell.order = route.orderList[indexPath.row]
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
    let movedOrder = route.orderList[sourceIndexPath.row]
    route.orderList.remove(at: sourceIndexPath.row)
    route.orderList.insert(movedOrder, at: destinationIndexPath.row)
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight.scaleHeight()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    performSegue(withIdentifier: SegueIdentifier.showOrderDetail, sender: route.orderList[indexPath.row])
    tabBarController?.tabBar.isHidden = true
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
