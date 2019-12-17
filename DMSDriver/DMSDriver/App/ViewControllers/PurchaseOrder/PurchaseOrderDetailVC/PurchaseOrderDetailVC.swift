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
    
    fileprivate var purchaseOrderInfo = [OrderDetailInforRow]()
    fileprivate var purchaseOrderPickup = [OrderDetailInforRow]()
    fileprivate var purchaseOrderDelivery = [OrderDetailInforRow]()
    fileprivate var purchaseOrderSKU = [OrderDetailInforRow]()
    fileprivate let purchaseDetailInfocellIdentifier = "OrderDetailTableViewCell"
    fileprivate let cellSKUInfoIdentifier = "PurchaseOrderSKUTableViewCell"
    fileprivate let headerCellIdentifier = "OrderDetailHeaderCell"
    fileprivate var arrTitleHeader:[String] = []
    
    fileprivate let cellHeight: CGFloat = 65.0
    
    var dateStringFilter = Date().toString()
    var order:PurchaseOrder?
    
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
        fetchData(showLoading: true)
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
        var _order:PurchaseOrder!
        if order != nil {
            _order = order!
        }
        purchaseOrderInfo.removeAll()
        purchaseOrderPickup.removeAll()
        purchaseOrderDelivery.removeAll()
        purchaseOrderSKU.removeAll()
        
        // Cell PurchaseOrder Info
        let purchaseId = OrderDetailInforRow("purchase-order-id".localized,IntSlash(_order.id))
        let purchaseOrderType = OrderDetailInforRow("order-type".localized, Slash(_order.orderType.name))
        let purchaseDivision = OrderDetailInforRow("division".localized,Slash(_order.division?.code))
        let purchaseRefCode = OrderDetailInforRow("ref-code".localized, Slash(_order.referenceCode))
        let purchaseCustomer = OrderDetailInforRow("customer-name".localized, Slash(_order.customer?.userName))
        let purchaseDueDateRange = OrderDetailInforRow("due-date-range".localized,Slash(_order.from?.start_time)+" - "+Slash(_order.to?.end_time))
        
        purchaseOrderInfo.append(purchaseId)
        purchaseOrderInfo.append(purchaseOrderType)
        purchaseOrderInfo.append(purchaseDivision)
        purchaseOrderInfo.append(purchaseRefCode)
        purchaseOrderInfo.append(purchaseCustomer)
        purchaseOrderInfo.append(purchaseDueDateRange)
        
        
        // Cell PurchaseOrder Pickup
        
        let purchasePUAddress = OrderDetailInforRow("address".localized, Slash(_order.from?.address))
        let purchasePUFloor = OrderDetailInforRow("floor".localized, Slash(_order.from?.floor))
        let purchasePUApartment = OrderDetailInforRow("apartment".localized, Slash(_order.from?.apartment))
        let purchasePUNumber = OrderDetailInforRow("number".localized, Slash(_order.from?.number))
        let purchasePUZone = OrderDetailInforRow("zone".localized, Slash(_order.zone?.name))
        let purchasePUConsigneeName = OrderDetailInforRow("consignee-name".localized, Slash(_order.from?.ctt_name))
        let purchasePUConsigneePhone = OrderDetailInforRow("consignee-phone".localized, Slash(_order.from?.ctt_phone))
        let purchasePUOpenTime = OrderDetailInforRow("open-time".localized, "-")
        let purchasePUCloseTime = OrderDetailInforRow("close-time".localized, "-")
        let purchasePUTimeRange = OrderDetailInforRow("time-range".localized, "-")
        let purchasePUServiceTime = OrderDetailInforRow("service-time".localized, "-")
        let purchasePUActualTime = OrderDetailInforRow("actual-time".localized, "-")
        
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
        
        let purchaseDeliveryAddress = OrderDetailInforRow("address".localized, Slash(_order.to?.address))
        let purchaseDeliveryFloor = OrderDetailInforRow("floor".localized, Slash(_order.to?.floor))
        let purchaseDeliveryApartment = OrderDetailInforRow("apartment".localized, Slash(_order.to?.apartment))
        let purchaseDeliveryNumber = OrderDetailInforRow("number".localized, Slash(_order.to?.number))
        let purchaseDeliveryZone = OrderDetailInforRow("zone".localized, Slash(_order.zone?.name))
        let purchaseDeliveryConsigneeName = OrderDetailInforRow("consignee-name".localized, Slash(_order.to?.ctt_name))
        let purchaseDeliveryConsigneePhone = OrderDetailInforRow("consignee-phone".localized, Slash(_order.to?.ctt_phone))
        let purchaseDeliveryOpenTime = OrderDetailInforRow("open-time".localized, "-")
        let purchaseDeliveryCloseTime = OrderDetailInforRow("close-time".localized, "-")
        let purchaseDeliveryTimeRange = OrderDetailInforRow("time-range".localized, "-")
        let purchaseDeliveryServiceTime = OrderDetailInforRow("service-time".localized, "-")
        let purchaseDeliveryActualTime = OrderDetailInforRow("actual-time".localized, "-")
        
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
                          "pickup".localized,
                          "Delivery".localized,
                          "items".localized]
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
            return order?.details?.count ?? 0
        case .Pickup:
            return order?.from == nil ? 0 : purchaseOrderPickup.count
        case .Delivery:
            return order?.to == nil ? 0 : purchaseOrderDelivery.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section:PurchaseOrderSection = PurchaseOrderSection(rawValue: section)!
        switch section {
        case .OrderInfo:
            return 50
        case .SKUS:
            return (order?.details?.count > 0) ? 50 : 0
        case .Pickup:
            return order?.from == nil ? 0 : 50
        case .Delivery:
            return order?.to == nil ? 0 : 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as? PurchaseOrderDetailTableViewCell{
            headerCell.nameLabel?.text = arrTitleHeader[section]
            if section == 0 {
                headerCell.contentLabel?.isHidden = false
                headerCell.contentLabel?.text = order?.status?.name?.localized
                headerCell.contentLabel?.textColor = order?.colorStatus
                
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
            let cell = tbvContent?.dequeueReusableCell(withIdentifier: cellSKUInfoIdentifier, for: indexPath) as! PurchaseOrderSKUTableViewCell
            guard let purchaseOrderDetail = order?.details?[indexPath.row] else {return cell}
            cell.configure(purchaseOrderSKU: purchaseOrderDetail)
            return cell
        case .Pickup:
            return purchaseOrderInfoCell(items: purchaseOrderPickup, tableView, indexPath)
        case .Delivery:
            return purchaseOrderInfoCell(items: purchaseOrderDelivery, tableView, indexPath)
        }
        
    }
    
    func purchaseOrderInfoCell(items:[OrderDetailInforRow],_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
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
            guard let _orderID = order?.id else { return }
            if !isFetch {
                showLoadingIndicator()
            }
            SERVICES().API.getPurchaseOrderDetail(orderId: "\(_orderID)") {[weak self] (result) in
                self?.dismissLoadingIndicator()
                switch result{
                case .object(let object):
                    guard let _orderDetail = object.data else { return }
                    self?.order = _orderDetail
                    self?.initVar()
                    self?.updateUI()
//                    CoreDataManager.updateOrderDetail(_orderDetail) // update orderdetail to DB local
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

