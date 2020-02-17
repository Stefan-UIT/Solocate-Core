//
//  RentingOrderDetailVC.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 9/24/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class RentingOrderDetailVC: BaseViewController {
    
    enum RentingOrderSection:Int {
        case OrderInfo = 0
        case SKUS
        
        static let count: Int = {
            var max: Int = 0
            while let _ = RentingOrderSection(rawValue: max) { max += 1 }
            return max
        }()
    }
    
    @IBOutlet weak var tbvContent: UITableView?
    @IBOutlet weak var statusButtonView: UIView!
    @IBOutlet weak var updateStatusButton: UIButton!
    @IBOutlet weak var cancelStatusButton: UIButton!
    
    @IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
    fileprivate var rentingOrderInfo = [RentingOrderDetailInforRow]()
    fileprivate var rentingSKUS = [RentingOrderDetailInforRow]()
    fileprivate let headerCellIdentifier = "RentingOrderDetailHeaderCell"
    fileprivate let rentingDetailInfocellIdentifier = "RentingOrderDetailInfoTableViewCell"
    fileprivate var scanItems = [String]()
    fileprivate var arrTitleHeader:[String] = []
    
    fileprivate let itemsIndex = 8
    fileprivate var scannedObjectIndexs = [Int]()
    fileprivate var shouldFilterOrderItemsList = true
    
    fileprivate let cellHeight: CGFloat = 65.0
    
    var dateStringFilter = Date().toString()
    var rentingOrder: RentingOrder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        fetchData(showLoading: true)
        setupTableView()
        initVar()
        setupDataDetailInforRows()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func updateNavigationBar() {
        setupNavigateBar()
    }
    
    //MARK: - Intialize
    func setupNavigateBar() {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.BackOnly, "renting-order-detail".localized)
    }
    
    func setupDataDetailInforRows() {
        var _rentingOrder:RentingOrder!
        if rentingOrder != nil {
            _rentingOrder = rentingOrder!
        }
        rentingOrderInfo.removeAll()
        rentingSKUS.removeAll()
        
        // Cell Renting Detail Info
        let rentingOrderID = RentingOrderDetailInforRow("renting-order-id".localized,"\(_rentingOrder.id)")
        let rentingRefCode = RentingOrderDetailInforRow("ref-code".localized,"\(_rentingOrder.referenceCode)")
        let rentingCustomer = RentingOrderDetailInforRow("customer-name".localized, Slash(_rentingOrder.rentingOrderCustomer?.userName))
        let rentingDateRange = RentingOrderDetailInforRow("date-range".localized,Slash(_rentingOrder.startDate?.rangeTime(_rentingOrder.endDate, true)))
        
        rentingOrderInfo.append(rentingOrderID)
        rentingOrderInfo.append(rentingRefCode)
        rentingOrderInfo.append(rentingCustomer)
        rentingOrderInfo.append(rentingDateRange)
        
    }
    
    override func updateUI()  {
        super.updateUI()
        tbvContent?.reloadData()
    }
    
    func initVar() {
        arrTitleHeader = ["order-info".localized,
                          "details".localized]
    }
    
    func setupTableView() {
        tbvContent?.estimatedRowHeight = cellHeight
        tbvContent?.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Action
    func handleFisnishedAction(itemId:Int, nextStatus: Int) {
        let alert = UIAlertController(title: "you-are-going-to-finish-this-detail-are-you-sure".localized, message: "", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "ok".localized, style: UIAlertAction.Style.default, handler: { action in
            // Call API
            self.updateRentingOrderStatus(nextStatus: nextStatus, rentingOrderDetailId: itemId, messageCancel: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleCancelAction(itemId:Int, nextStatus: Int) {
        let alert = UIAlertController(title: "please-input-the-reason".localized, message: "", preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "submit".localized, style: .default, handler: { (action) -> Void in
            // Get TextFields text
            let numberOfRequestTxt = alert.textFields![0]
            let reason = numberOfRequestTxt.text
            // Call API
            self.updateRentingOrderStatus(nextStatus: nextStatus, rentingOrderDetailId: itemId, messageCancel: reason)
        })
        submitAction.isEnabled = false
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        // textField
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = ""
            textField.keyboardType = .asciiCapableNumberPad
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
                {_ in
                    let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textIsNotEmpty = textCount > 0
                    submitAction.isEnabled = textIsNotEmpty
            })
        }
        
        // Add actions
        alert.addAction(cancel)
        alert.addAction(submitAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension RentingOrderDetailVC: DMSNavigationServiceDelegate {
    func didSelectedBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableView
extension RentingOrderDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrTitleHeader.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section:RentingOrderSection = RentingOrderSection(rawValue: section)!
        switch section {
        case .OrderInfo:
            return rentingOrderInfo.count
        case .SKUS:
            return rentingOrder?.rentingOrderDetails?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as? RentingOrderDetailInfoTableViewCell{
            headerCell.nameLabel?.text = arrTitleHeader[section]
            if section == 0 {
                headerCell.contentLabel?.isHidden = false
                headerCell.contentLabel?.text = rentingOrder?.rentingOrderStatus?.name?.localized
                headerCell.contentLabel?.textColor = rentingOrder?.rentingOrderStatusColor
                
            } else {
                headerCell.contentLabel?.isHidden = true
            }
            return headerCell
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view:UIView = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section:RentingOrderSection = RentingOrderSection(rawValue: indexPath.section)!
        switch section {
        case .OrderInfo:
            return rentingOrderInfoCell(items: rentingOrderInfo, tableView, indexPath)
        case .SKUS:
            let cell = tbvContent?.dequeueReusableCell(withIdentifier: "RentingOrderDetailTableViewCell", for: indexPath) as! RentingOrderDetailTableViewCell
            guard let rentingOrderDetail = rentingOrder?.rentingOrderDetails?[indexPath.row] else {return cell}
            cell.delegate = self
            cell.rentingOrderDetail = rentingOrderDetail
            cell.configureCellWithRentingOrderDetail(rentingOrderDetail)
            return cell
        }
            
    }
    
    func rentingOrderInfoCell(items:[RentingOrderDetailInforRow],_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: rentingDetailInfocellIdentifier, for: indexPath) as! RentingOrderDetailInfoTableViewCell
        cell.rentingOrderDetailItem = item
        cell.selectionStyle = .none
        return cell
        
    }
    
}

//MARK: API
extension RentingOrderDetailVC {
    func fetchData(showLoading:Bool = false)  {
        getRentingOrderDetail(isFetch: showLoading)
    }
    
    private func getRentingOrderDetail(isFetch:Bool = false) {
        if ReachabilityManager.isNetworkAvailable {
            guard let _rentingOrderID = rentingOrder?.id else { return }
            if !isFetch {
                showLoadingIndicator()
            }
            SERVICES().API.getRentingOrderDetail(rentingOrderId: "\(_rentingOrderID)") {[weak self] (result) in
                self?.dismissLoadingIndicator()
                switch result{
                case .object(let object):
                    if let _rentingOrder = object.data {
                        self?.rentingOrder = _rentingOrder
                        CoreDataManager.updateRentingOrder(_rentingOrder) // update rentingOrderDetail to DB local
                    }
//                    self?.rootVC?.order =  self?.orderDetail
                    self?.initVar()
                    self?.updateUI()
                case .error(let error):
                    self?.showAlertView(error.getMessage())
                }
            }
            
        }else {
            //Get data from local DB
            if let _rentingOrder = self.rentingOrder {
                self.rentingOrder = CoreDataManager.getRentingOrder(_rentingOrder.id)
                self.initVar()
                self.updateUI()
            }
        }
    }
    
    func updateRentingOrderStatus(nextStatus: Int, rentingOrderDetailId: Int, messageCancel: String?){
        SERVICES().API.updateRentingOrderStatus(nextStatus: nextStatus, rentingOrderDetailId: rentingOrderDetailId, message: messageCancel) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.showAlertView(MSG_UPDATED_SUCCESSFUL)
                self?.fetchData()
                break
            case .error(let error):
                self?.showAlertView(error.getMessage(), completionHandler: { (action) in
                    self?.fetchData(showLoading: true)
                })
            }
        }
    }
}

extension RentingOrderDetailVC: RentingOrderDetailTableViewCellDelegate {
    func cancelOrder(itemId: Int, nextStatus: Int) {
        self.handleCancelAction(itemId: itemId, nextStatus: nextStatus)
    }
    
    func updateStatus(itemId: Int, nextStatus: Int) {
        self.handleFisnishedAction(itemId: itemId, nextStatus: nextStatus)
    }
}
