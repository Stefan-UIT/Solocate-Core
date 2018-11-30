//
//  ReasonListViewController.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 3/21/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class ReasonListViewController: BaseViewController {
    
    enum ReasonDisplayMode:String {
        case displayModeOrder = "1"
        case displayModeTask = "2"
    }
    
    
    fileprivate var reasonList:[Reason] = [Reason]()
    fileprivate var selectedIndex: Int = -1
    var orderDetail: OrderDetail?
    var task: TaskModel?

    var routeID: Int = -1
    var itemID: String?
    
    var didCancelSuccess:((_ success:Bool,_ data: Any) -> Void)?
    var displayMode:ReasonDisplayMode = .displayModeOrder
    
  
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
    }
    

    override func reachabilityChangedNotification(_ notification: NSNotification) {
        super.reachabilityChangedNotification(notification)
        getReasonList()
    }
    
    override func updateUI()  {
       super.updateUI()
        DispatchQueue.main.async {
            switch self.displayMode{
            case .displayModeOrder:
                if let _orderDetail = self.orderDetail {
                    let unableTitle = _orderDetail.statusOrder == .newStatus ? "Unable To Start".localized : "Unable To Finish".localized
                    self.finishButton.setTitle(unableTitle, for: .normal)
                }
                
            case .displayModeTask:
                self.finishButton.setTitle("cancel".localized, for: .normal)
            }
        
            self.setupTextView()
        }
    }
    
    override func updateNavigationBar() {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.BackOnly, "Select Reason".localized)
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
        
        switch displayMode {
        case .displayModeOrder:
            self.cancelOrder()
            
        case .displayModeTask:
            self.cancelTask(task!)
        }
    }
}

//MARK : API
extension ReasonListViewController {
    func getReasonList() {
        if hasNetworkConnection {
            showLoadingIndicator()
            API().getReasonList(displayMode.rawValue) {[weak self] (result) in
                self?.dismissLoadingIndicator()
                switch result{
                case .object(let obj):
                    guard let list = obj.data else {return}
                    self?.reasonList.append(contentsOf: list)
                    self?.tableView.reloadData()
                    
                    CoreDataManager.updateListReason(list) // Update reason list to local DB
                    
                case .error(let error):
                    self?.showAlertView(error.getMessage())
                }
            }
            
        }else{
            DispatchQueue.main.async {
                self.reasonList.append(contentsOf: CoreDataManager.getListReason())
                self.tableView.reloadData()
            }
        }
    }
    
    func cancelOrder() {
        orderDetail?.statusCode = "CC"
        orderDetail?.route_id = routeID
        guard let order = orderDetail else{return}
        let reason = reasonList[selectedIndex]
        reason.message = tvMessange?.text
        
        if  !hasNetworkConnection {
            order.reason = reason
            CoreDataManager.updateOrderDetail(order) // Save to local DB
            self.didCancelSuccess?(true, order)
            self.navigationController?.popViewController(animated: true)
        }
        
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
    
    func cancelTask(_ task:TaskModel) {
        self.showLoadingIndicator()
        let reason = reasonList[selectedIndex]
        reason.message = tvMessange?.text
        API().updateTaskStatusTask(task.task_id ?? 0, "CC",reason) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.tableView?.endRefreshControl()
            switch result{
            case .object(_ ):
                self?.didCancelSuccess?(true, task)
                self?.navigationController?.popViewController(animated: true)
                
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "ReasonListCell", for: indexPath) as! ReasonListCell
    
    cell.lblTitle?.text =  reasonList[indexPath.row].name
    cell.lblSubtitle?.text = ""
    if selectedIndex == indexPath.row {
        cell.imgIcon?.image = UIImage(named: "ic_selected")
    }else{
        cell.imgIcon?.image = UIImage(named: "ic_nonselected")
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedIndex = indexPath.row
    tableView.reloadData()
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
