//
//  ReasonListViewController.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 3/21/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class ReasonListViewController: BaseViewController {
  fileprivate var reasonList:[Reason] = [Reason]()
  fileprivate var selectedIndex: Int = -1
  var orderDetail: OrderDetail?
  var routeID: Int?
  var type: String = "1"
  var itemID: String?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var finishButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let _orderDetail = orderDetail, type == "1" {
        let unableTitle = _orderDetail.statusCode == "OP" ? "order_detail_unable_start".localized : "order_detail_unable_finish".localized
        finishButton.setTitle(unableTitle, for: .normal)
    }
    getReasonList()
    title = "reason_list_title".localized
  }
  
  @IBAction func submit(_ sender: UIButton) {
    guard selectedIndex >= 0 else {
      showAlertView("reason_choose_at_least_reason".localized)
      return
    }
    if let id = itemID, type == "2" { // for item
      APIs.updateOrderItemStatus(id, status: "CC", reason: reasonList[selectedIndex], completion: { [unowned self] (errMsg) in
        if let msg = errMsg {
          self.showAlertView(msg)
        }
        else {
          self.navigationController?.popToRootViewController(animated: true)
        }
      })      
      return
    }
    
    // for order
    guard let _orderDetail = orderDetail,
      let _routeID = routeID else { return }
    showLoadingIndicator()
    let status = _orderDetail.statusCode == "OP" ? "US" : "UF"
    APIs.updateOrderStatus("\(_orderDetail.id)", expectedStatus: status, routeID: "\(_routeID)", reason: reasonList[selectedIndex]) { (errMsg) in
      self.dismissLoadingIndicator()
      if let err = errMsg {
        self.showAlertView(err)
      }
      else {
        self.navigationController?.popToRootViewController(animated: true)
      }
    }
  }
  
}

extension ReasonListViewController {
  func getReasonList() {
    showLoadingIndicator()
    APIs.getReasonList(type, completion: { [unowned self] (response, errMsg) in
      self.dismissLoadingIndicator()
      guard let list = response else {
        self.showAlertView(errMsg ?? "")
        return
      }
      self.reasonList.append(contentsOf: list)
      self.tableView.reloadData()
    })
  }
}

extension ReasonListViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reasonList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
    cell.textLabel?.text = reasonList[indexPath.row].name
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if selectedIndex >= 0 {
      let previousCell = tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0))
      previousCell?.accessoryType = .none
    }
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType = .checkmark
    selectedIndex = indexPath.row
  }
}
