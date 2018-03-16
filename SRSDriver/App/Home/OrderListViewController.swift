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
  fileprivate let cellHeight: CGFloat = 130.0
  
  fileprivate var route: Route! {
    didSet {
      guard route.orderList.count > 0 else {
        noOrdersLabel.isHidden = false
        tableView.isHidden = true
        navigationItem.rightBarButtonItem?.isEnabled = false
        return
      }
      noOrdersLabel.isHidden = true
      tableView.isHidden = false
      navigationItem.rightBarButtonItem?.isEnabled = true
      tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getOrders()
    tabBarController?.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let dateString = datePickerView.date.toString()
    navigationItem.title = dateString
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.title = ""// clear title
  }
  
  @IBAction func didPickDate(_ sender: UIDatePicker) {
    navigationItem.title = sender.date.toString()
  }
  
  @IBAction func didChooseCalendar(_ sender: UIBarButtonItem) {
    let dateString = datePickerView.date.toString("yyyy-MM-dd")
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
    sender.title = tableView.isEditing ? "Done" : "Edit"
  }
  
  @IBAction func logout(_ sender: UIBarButtonItem) {
    Cache.shared.setObject(obj: "", forKey: Defaultkey.tokenKey)
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
    if segue.identifier == SegueIdentifier.orderDetail,
      let destVC = segue.destination as? OrderDetailContainerViewController,
      let order = sender as? Order {
      destVC.orderID = "\(order.id)"
    }
  }
}

// MARK: - Private methods

extension OrderListViewController {
  func getOrders(byDate date: String? = nil) {
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
    //    let movedObject = self.fruits[sourceIndexPath.row]
    //    fruits.remove(at: sourceIndexPath.row)
    //    fruits.insert(movedObject, at: destinationIndexPath.row)
    //    NSLog("%@", "\(sourceIndexPath.row) => \(destinationIndexPath.row) \(fruits)")
    // To check for correctness enable: self.tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight.scaleHeight()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: SegueIdentifier.orderDetail, sender: route.orderList[indexPath.row])
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
}


extension OrderListViewController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    if let navigationController = viewController as? UINavigationController,
      let mapVC = navigationController.topViewController as? MapsViewController {
      mapVC.route = route
    }
  }
}
