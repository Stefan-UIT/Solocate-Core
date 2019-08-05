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
    var orderDetail: Order?
    var task: TaskModel?

    var routeID: Int = -1
    var itemID: String?
    
    var didCancelSuccess:((_ success:Bool,_ data: Any) -> Void)?
    var displayMode:ReasonDisplayMode = .displayModeOrder
    
  
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var finishButton: UIButton?
    @IBOutlet weak var tvMessange: UITextView?
    @IBOutlet weak var lblPlaceholder: UILabel?
    @IBOutlet weak var btnBack: UIButton?

    
    var validateSubmit:Bool = false{
        didSet{
            finishButton?.isEnabled = validateSubmit
            finishButton?.alpha = validateSubmit ? 1 : 0.4
        }
    }

  
    override func viewDidLoad() {
        super.viewDidLoad()
        validateSubmit = false
        updateUI()
        getReasonList()
    }
    
    override func reachabilityChangedNetwork(_ isAvailaibleNetwork: Bool) {
        super.reachabilityChangedNetwork(isAvailaibleNetwork)
    }

    override func updateUI()  {
       super.updateUI()
        DispatchQueue.main.async {
            switch self.displayMode{
            case .displayModeOrder:
                if let _orderDetail = self.orderDetail {
                    let unableTitle = _orderDetail.statusOrder == .newStatus ? "unable-to-start".localized.uppercased() : "unable-to-finish".localized.uppercased()
                    self.finishButton?.setTitle(unableTitle, for: .normal)
                }
                
            case .displayModeTask:
                self.finishButton?.setTitle("cancel".localized, for: .normal)
            }
        
            self.setupTextView()
        }
    }
    
    override func updateNavigationBar() {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.BackOnly, "select-reason".localized)
    }
    
    func setupTextView()  {
        tvMessange?.delegate = self
        lblPlaceholder?.text = "enter-a-message".localized
    }
  
    
    // MARK: - ACTION
    @IBAction func submit(_ sender: UIButton) {
        guard selectedIndex >= 0 else {
            showAlertView("please-select-at-least-one-reason".localized)
            return
        }
        
        switch displayMode {
        case .displayModeOrder:
            if orderDetail?.statusOrder == .newStatus{
                self.cancelOrder(statusCode: "CC") // Unable start
            }else{
                self.cancelOrder(statusCode: "UF") // Unable finish
            }
            
        case .displayModeTask:
            self.cancelTask(task!)
        }
    }
    
    @IBAction func onbtnClickback(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK : API
extension ReasonListViewController {
    func getReasonList() {
        if hasNetworkConnection {
            showLoadingIndicator()
            SERVICES().API.getReasonList {[weak self] (result) in
                self?.dismissLoadingIndicator()
                switch result{
                case .object(let obj):
                    guard let list = obj.data else {return}
                    self?.reasonList.append(contentsOf: list)
                    self?.tableView.reloadData()
                    
                    //CoreDataManager.updateListReason(list) // Update reason list to local DB
                    
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
    
    func cancelOrder(statusCode:String) {
        let listStatus =  CoreDataManager.getListStatus()
        for item in listStatus {
            if item.code == statusCode{
                orderDetail?.status = item
                break
            }
        }
        guard let order = orderDetail else{return}
        let reason = reasonList[selectedIndex]
        reason.message = tvMessange?.text
        
        if  !hasNetworkConnection {
            order.reason = reason
            //CoreDataManager.updateOrderDetail(order) // Save to local DB
            self.didCancelSuccess?(true, order)
            self.navigationController?.popViewController(animated: true)
        }
        
        SERVICES().API.updateOrderStatus(order, reason: reason) {[weak self] (result) in
            switch result{
            case .object(_ ):
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
        SERVICES().API.updateTaskStatusTask(task.id, "CC",reason) {[weak self] (result) in
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
