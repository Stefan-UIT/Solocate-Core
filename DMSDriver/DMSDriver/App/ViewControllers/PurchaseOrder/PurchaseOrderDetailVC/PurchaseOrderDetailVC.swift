//
//  PurchaseOrderDetailVC.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 12/16/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class PurchaseOrderDetailVC: BaseViewController {
    
    enum PurchaseOrderSection:Int {
        case OrderInfo = 0
        case Pickup
        case Delivery
        case SKUS
        
        static let count: Int = {
            var max: Int = 0
            while let _ = PurchaseOrderSection(rawValue: max) { max += 1 }
            return max
        }()
    }
    
    @IBOutlet weak var tbvContent: UITableView?
    
    fileprivate var purchaseOrderInfo = [PurchaseOrderDetailInforRow]()
    fileprivate var purchaseOrderPickup = [PurchaseOrderDetailInforRow]()
    fileprivate var purchaseOrderDelivery = [PurchaseOrderDetailInforRow]()
    fileprivate var purchaseOrderSKU = [PurchaseOrderDetailInforRow]()
    fileprivate let headerCellIdentifier = "PurchaseOrderDetailHeaderCell"
    fileprivate let purchaseDetailInfocellIdentifier = "PurchaseOrderDetailTableViewCell"
    fileprivate var arrTitleHeader:[String] = []
    
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
        App().navigationService.updateNavigationBar(.BackOnly, "purchase-order-detail".localized)
    }
    
    func setupDataDetailInforRows() {
        var _rentingOrder:RentingOrder!
        if rentingOrder != nil {
            _rentingOrder = rentingOrder!
        }
        purchaseOrderInfo.removeAll()
        purchaseOrderPickup.removeAll()
        purchaseOrderDelivery.removeAll()
        purchaseOrderSKU.removeAll()
        
        // Cell PurchaseOrder Info
        let purchaseId = PurchaseOrderDetailInforRow("purchase-order-id".localized,"-")
        let purchaseDivision = PurchaseOrderDetailInforRow("division".localized,"-")
        let purchaseRefCode = PurchaseOrderDetailInforRow("ref-code".localized, "-")
        let purchaseCustomer = PurchaseOrderDetailInforRow("customer-name".localized, "-")
        let purchaseDueDateRange = PurchaseOrderDetailInforRow("due-date-range".localized,"13/12/2019 11:00"+" - "+"14/12/2019 11:00")
        
        purchaseOrderInfo.append(purchaseId)
        purchaseOrderInfo.append(purchaseDivision)
        purchaseOrderInfo.append(purchaseRefCode)
        purchaseOrderInfo.append(purchaseCustomer)
        purchaseOrderInfo.append(purchaseDueDateRange)
        
        
        // Cell PurchaseOrder Pickup
        
        let purchasePUAddress = PurchaseOrderDetailInforRow("address".localized, "-")
        let purchasePUFloor = PurchaseOrderDetailInforRow("floor".localized, "-")
        let purchasePUApartment = PurchaseOrderDetailInforRow("apartment".localized, "-")
        let purchasePUNumber = PurchaseOrderDetailInforRow("number".localized, "-")
        let purchasePUZone = PurchaseOrderDetailInforRow("zone".localized, "-")
        let purchasePUConsigneeName = PurchaseOrderDetailInforRow("consignee-name".localized, "-")
        let purchasePUConsigneePhone = PurchaseOrderDetailInforRow("consignee-phone".localized, "-")
        let purchasePUOpenTime = PurchaseOrderDetailInforRow("open-time".localized, "-")
        let purchasePUCloseTime = PurchaseOrderDetailInforRow("close-time".localized, "-")
        let purchasePUTimeRange = PurchaseOrderDetailInforRow("time-range".localized, "-")
        let purchasePUServiceTime = PurchaseOrderDetailInforRow("service-time".localized, "-")
        let purchasePUActualTime = PurchaseOrderDetailInforRow("actual-time".localized, "-")
        
        purchaseOrderPickup.append(purchasePUAddress)
        purchaseOrderPickup.append(purchasePUFloor)
        purchaseOrderPickup.append(purchasePUApartment)
        purchaseOrderPickup.append(purchasePUNumber)
        purchaseOrderPickup.append(purchasePUZone)
        purchaseOrderPickup.append(purchasePUConsigneeName)
        purchaseOrderPickup.append(purchasePUConsigneePhone)
        purchaseOrderPickup.append(purchasePUOpenTime)
        purchaseOrderPickup.append(purchasePUCloseTime)
        purchaseOrderPickup.append(purchasePUTimeRange)
        purchaseOrderPickup.append(purchasePUServiceTime)
        purchaseOrderPickup.append(purchasePUActualTime)
        
        
        // Cell PurchaseOrder Delivery
        
        let purchaseDeliveryAddress = PurchaseOrderDetailInforRow("address".localized, "-")
        let purchaseDeliveryFloor = PurchaseOrderDetailInforRow("floor".localized, "-")
        let purchaseDeliveryApartment = PurchaseOrderDetailInforRow("apartment".localized, "-")
        let purchaseDeliveryNumber = PurchaseOrderDetailInforRow("number".localized, "-")
        let purchaseDeliveryZone = PurchaseOrderDetailInforRow("zone".localized, "-")
        let purchaseDeliveryConsigneeName = PurchaseOrderDetailInforRow("consignee-name".localized, "-")
        let purchaseDeliveryConsigneePhone = PurchaseOrderDetailInforRow("consignee-phone".localized, "-")
        let purchaseDeliveryOpenTime = PurchaseOrderDetailInforRow("open-time".localized, "-")
        let purchaseDeliveryCloseTime = PurchaseOrderDetailInforRow("close-time".localized, "-")
        let purchaseDeliveryTimeRange = PurchaseOrderDetailInforRow("time-range".localized, "-")
        let purchaseDeliveryServiceTime = PurchaseOrderDetailInforRow("service-time".localized, "-")
        let purchaseDeliveryActualTime = PurchaseOrderDetailInforRow("actual-time".localized, "-")
        
        purchaseOrderDelivery.append(purchaseDeliveryAddress)
        purchaseOrderDelivery.append(purchaseDeliveryFloor)
        purchaseOrderDelivery.append(purchaseDeliveryApartment)
        purchaseOrderDelivery.append(purchaseDeliveryNumber)
        purchaseOrderDelivery.append(purchaseDeliveryZone)
        purchaseOrderDelivery.append(purchaseDeliveryConsigneeName)
        purchaseOrderDelivery.append(purchaseDeliveryConsigneePhone)
        purchaseOrderDelivery.append(purchaseDeliveryOpenTime)
        purchaseOrderDelivery.append(purchaseDeliveryCloseTime)
        purchaseOrderDelivery.append(purchaseDeliveryTimeRange)
        purchaseOrderDelivery.append(purchaseDeliveryServiceTime)
        purchaseOrderDelivery.append(purchaseDeliveryActualTime)
        
    }
    
    override func updateUI()  {
        super.updateUI()
        tbvContent?.reloadData()
    }
    
    func initVar() {
        arrTitleHeader = ["order-info".localized,
                          "items".localized,
                          "pickup".localized,
                          "Delivery".localized]
    }
    
    func setupTableView() {
        tbvContent?.estimatedRowHeight = cellHeight
        tbvContent?.rowHeight = UITableView.automaticDimension
    }
    
}

extension PurchaseOrderDetailVC: DMSNavigationServiceDelegate {
    func didSelectedBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableView
extension PurchaseOrderDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrTitleHeader.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section:PurchaseOrderSection = PurchaseOrderSection(rawValue: section)!
        switch section {
        case .OrderInfo:
            return purchaseOrderInfo.count
        case .SKUS:
            return rentingOrder?.rentingOrderDetails?.count ?? 0
        case .Pickup:
            return purchaseOrderPickup.count
        case .Delivery:
            return purchaseOrderDelivery.count
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
        let section:PurchaseOrderSection = PurchaseOrderSection(rawValue: indexPath.section)!
        switch section {
        case .OrderInfo:
            return purchaseOrderInfoCell(items: purchaseOrderInfo, tableView, indexPath)
        case .SKUS:
            let cell = tbvContent?.dequeueReusableCell(withIdentifier: "RentingOrderDetailTableViewCell", for: indexPath) as! RentingOrderDetailTableViewCell
            guard let rentingOrderDetail = rentingOrder?.rentingOrderDetails?[indexPath.row] else {return cell}
            cell.configureCellWithRentingOrderDetail(rentingOrderDetail)
            return cell
        case .Pickup:
            return purchaseOrderInfoCell(items: purchaseOrderPickup, tableView, indexPath)
        case .Delivery:
            return purchaseOrderInfoCell(items: purchaseOrderDelivery, tableView, indexPath)
        }
        
    }
    
    func purchaseOrderInfoCell(items:[PurchaseOrderDetailInforRow],_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: purchaseDetailInfocellIdentifier, for: indexPath) as! PurchaseOrderDetailTableViewCell
        cell.purchaseOrderDetailItem = item
        cell.selectionStyle = .none
        return cell
        
    }
}

//MARK: API
extension PurchaseOrderDetailVC {
    func fetchData(showLoading:Bool = false)  {
        getRentingOrderDetail()
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
//                        CoreDataManager.updateRentingOrder(_rentingOrder) // update rentingOrderDetail to DB local
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
//            if let _rentingOrder = self.rentingOrder {
//                self.rentingOrder = CoreDataManager.getRentingOrder(_rentingOrder.id)
//                self.initVar()
//                self.updateUI()
//            }
        }
    }
    
}

