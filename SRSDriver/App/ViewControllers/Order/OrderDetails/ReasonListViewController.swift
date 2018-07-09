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
    updateUI()
    getReasonList()
  }
    
  func updateUI()  {
    if let _orderDetail = orderDetail, type == "1" {
      let unableTitle = _orderDetail.status == .newStatus ? "order_detail_unable_start".localized : "order_detail_unable_finish".localized
            finishButton.setTitle(unableTitle, for: .normal)
    }
  }
    
  override func updateNavigationBar() {
    self.navigationService.delegate = self
    self.navigationService.updateNavigationBar(.BackOnly, "Select Reason")
  }
  
  @IBAction func submit(_ sender: UIButton) {
    guard selectedIndex >= 0 else {
      showAlertView("reason_choose_at_least_reason".localized)
      return
    }

    orderDetail?.statusCode = "CC"
    orderDetail?.routeId = routeID!
    guard let order = orderDetail else{return}
    API().updateOrderStatus(order, reason: reasonList[selectedIndex]) { (result) in
        switch result{
        case .object(_):
            self.navigationController?.popViewController(animated: true)
        case .error(let error):
            self.showAlertView(error.getMessage())
        }
    }
  }
}

extension ReasonListViewController {
  func getReasonList() {
    showLoadingIndicator()
    API().getReasonList {[weak self] (result) in
        self?.dismissLoadingIndicator()
        switch result{
        case .object(let obj):
            guard let list = obj.data else {return}
            self?.reasonList.append(contentsOf: list)
            self?.tableView.reloadData()
            
        case .error(let error):
            self?.showAlertView(error.getMessage())
        }
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

extension ReasonListViewController:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        self.navigationController?.popViewController(animated: true)

    }
}
