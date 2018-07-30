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
    
  var didCancelSuccess:((_ success:Bool,_ data: OrderDetail) -> Void)?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var finishButton: UIButton!
  @IBOutlet weak var tvMessange: UITextView?
  @IBOutlet weak var lblPlaceholder: UILabel?
    
    
  var validateSubmit:Bool = false{
    didSet{
        finishButton.isEnabled = validateSubmit
        finishButton.alpha = validateSubmit ? 1 : 0.4
    }
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    validateSubmit = false
    updateUI()
    getReasonList()
  }
    
  func updateUI()  {
    if let _orderDetail = orderDetail, type == "1" {
      let unableTitle = _orderDetail.status == .newStatus ? "Unable To Start".localized : "Unable To Finish".localized
            finishButton.setTitle(unableTitle, for: .normal)
    }
    
    setupTextView()
  }
    
  override func updateNavigationBar() {
    self.navigationService.delegate = self
    self.navigationService.updateNavigationBar(.BackOnly, "Select Reason".localized)
  }
    
    func setupTextView()  {
        tvMessange?.delegate = self
        lblPlaceholder?.text = "Enter a message".localized
    
    }
  
    
  // MARK: - ACTION
  @IBAction func submit(_ sender: UIButton) {
    guard selectedIndex >= 0 else {
      showAlertView("Please select at least one reason".localized)
      return
    }

    orderDetail?.statusCode = "CC"
    orderDetail?.routeId = routeID!
    guard let order = orderDetail else{return}
    let reason = reasonList[selectedIndex]
    reason.message = tvMessange?.text
    API().updateOrderStatus(order, reason: reason) {[weak self] (result) in
        switch result{
        case .object(_):
            self?.didCancelSuccess?(true, order)
            self?.navigationController?.popViewController(animated: true)
        case .error(let error):
            self?.showAlertView(error.getMessage())
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

extension ReasonListViewController:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        lblPlaceholder?.isHidden = (textView.text.length > 0)
        validateSubmit = (textView.text.length > 0)
    }
}
