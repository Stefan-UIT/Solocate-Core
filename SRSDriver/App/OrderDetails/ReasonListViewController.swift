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
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var finishButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getReasonList()
    if let _orderDetail = orderDetail {
      let unableTitle = _orderDetail.statusCode == "OP" ? "Unable to Start" : "Unable to Finish"
      finishButton.setTitle(unableTitle, for: .normal)
    }
    title = "Choose a reason"
  }
  
  @IBAction func submit(_ sender: UIButton) {
    guard selectedIndex >= 0 else {
      showAlertView("Plz choose at least a reason")
      return
    }
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
    APIs.getReasonList { [unowned self] (response, errMsg) in
      self.dismissLoadingIndicator()
      guard let list = response else {
        self.showAlertView(errMsg ?? "")
        return
      }
      self.reasonList.append(contentsOf: list)
      self.tableView.reloadData()
    }
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
