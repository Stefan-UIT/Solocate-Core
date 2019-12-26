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
    
    fileprivate let CELL_HEIGHT: CGFloat = 65.0
    fileprivate let FOOTER_HEIGHT: CGFloat = 15.0
    
    var dateStringFilter = Date().toString()
    var order:PurchaseOrder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        fetchData(showLoading: true)
        initVar()
        
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
        let purchaseDivision = OrderDetailInforRow("division".localized,Slash(_order.division?.name))
        let purchaseRefCode = OrderDetailInforRow("ref-code".localized, Slash(_order.referenceCode))
        let purchaseCustomer = OrderDetailInforRow("customer-name".localized, Slash(_order.customer?.userName))
        let purchaseDueDateRange = OrderDetailInforRow("due-date-range".localized, Slash(_order.dueDateFrom?.rangeTime(_order.dueDateTo)))
        let purchaseZone = OrderDetailInforRow("zone".localized, Slash(_order.zone?.name))
        
        purchaseOrderInfo.append(purchaseId)
        purchaseOrderInfo.append(purchaseOrderType)
        purchaseOrderInfo.append(purchaseDivision)
        purchaseOrderInfo.append(purchaseRefCode)
        purchaseOrderInfo.append(purchaseCustomer)
        purchaseOrderInfo.append(purchaseDueDateRange)
        purchaseOrderInfo.append(purchaseZone)
        
        
        // Cell PurchaseOrder Pickup
        var fromOpenTime = ""
        var fromCloseTime = ""
        if let start = _order.from?.openTime?.date {
            fromOpenTime = Hour24Formater.string(from:start)
        }
        if let end = _order.from?.closeTime?.date {
            fromCloseTime = Hour24Formater.string(from:end)
        }
        let purchasePUAddress = OrderDetailInforRow("address".localized, Slash(_order.from?.address))
        let fromFloor = Slash(_order.from?.floor)
        let fromApartment = Slash(_order.from?.apartment)
        let fromNumber = Slash(_order.from?.number)
        let fromAddressDetail = "\(fromFloor)/\(fromApartment)/\(fromNumber)"
        let fromAddressDetailRecord = OrderDetailInforRow("floor-apt-number".localized,fromAddressDetail,false)
        let purchasePUConsigneeName = OrderDetailInforRow("consignee-name".localized, Slash(_order.from?.ctt_name))
        let purchasePUConsigneePhone = OrderDetailInforRow("consignee-phone".localized, Slash(_order.from?.ctt_phone))
        let purchasePUOpenTime = OrderDetailInforRow("open-time".localized, Slash(fromOpenTime))
        let purchasePUCloseTime = OrderDetailInforRow("close-time".localized, Slash(fromCloseTime))
        let purchasePUTimeRange = OrderDetailInforRow("time-range".localized, Slash(_order.from?.start_time?.rangeTime(_order.from?.end_time)))
        let purchasePUServiceTime = OrderDetailInforRow("service-time".localized, IntSlash(_order.from?.srvc_time))
        let purchasePUActualTime = OrderDetailInforRow("actual-time".localized, Slash(_order.from?.actualTime))
        
        purchaseOrderPickup.append(purchasePUAddress)
        purchaseOrderPickup.append(fromAddressDetailRecord)
        purchaseOrderPickup.append(purchasePUConsigneeName)
        purchaseOrderPickup.append(purchasePUConsigneePhone)
        purchaseOrderPickup.append(purchasePUOpenTime)
        purchaseOrderPickup.append(purchasePUCloseTime)
        purchaseOrderPickup.append(purchasePUTimeRange)
        purchaseOrderPickup.append(purchasePUServiceTime)
        purchaseOrderPickup.append(purchasePUActualTime)
        
        
        // Cell PurchaseOrder Delivery
        var toOpenTime = ""
        var toCloseTime = ""
        if let start = _order.to?.openTime?.date {
            toOpenTime = Hour24Formater.string(from:start)
        }
        if let end = _order.to?.closeTime?.date {
            toCloseTime = Hour24Formater.string(from:end)
        }
        let purchaseDeliveryAddress = OrderDetailInforRow("Address".localized, Slash(_order.to?.address))
        let toFloor = Slash(_order.to?.floor)
        let toApartment = Slash(_order.to?.apartment)
        let toNumber = Slash(_order.to?.number)
        let toAddressDetail = "\(toFloor)/\(toApartment)/\(toNumber)"
        let toAddressDetailRecord = OrderDetailInforRow("floor-apt-number".localized,toAddressDetail,false)
        let purchaseDeliveryConsigneeName = OrderDetailInforRow("consignee-name".localized, Slash(_order.to?.ctt_name))
        let purchaseDeliveryConsigneePhone = OrderDetailInforRow("consignee-phone".localized, Slash(_order.to?.ctt_phone))
        let purchaseDeliveryOpenTime = OrderDetailInforRow("open-time".localized, Slash(toOpenTime))
        let purchaseDeliveryCloseTime = OrderDetailInforRow("close-time".localized, Slash(toCloseTime))
        let purchaseDeliveryTimeRange = OrderDetailInforRow("time-range".localized, Slash(_order.to?.start_time?.rangeTime(_order.to?.end_time)))
        let purchaseDeliveryServiceTime = OrderDetailInforRow("service-time".localized, IntSlash(_order.to?.srvc_time))
        let purchaseDeliveryActualTime = OrderDetailInforRow("actual-time".localized, Slash(_order.to?.actualTime))
        
        purchaseOrderDelivery.append(purchaseDeliveryAddress)
        purchaseOrderDelivery.append(toAddressDetailRecord)
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
        setupDataDetailInforRows()
        tbvContent?.reloadData()
    }
    
    func initVar() {
        arrTitleHeader = ["order-info".localized,
                          "pickup".localized,
                          "Delivery".localized,
                          "items".localized]
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
        return CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section:PurchaseOrderSection = PurchaseOrderSection(rawValue: section)!
        switch section {
        case .OrderInfo:
            return 50
        case .SKUS:
            return (order?.details?.count > 0) ? 50 : CGFloat.leastNormalMagnitude
        case .Pickup:
            return order?.from == nil ? CGFloat.leastNormalMagnitude : 50
        case .Delivery:
            return order?.to == nil ? CGFloat.leastNormalMagnitude : 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as? PurchaseOrderDetailTableViewCell{
            headerCell.nameLabel?.text = arrTitleHeader[section]
            let section:PurchaseOrderSection = PurchaseOrderSection(rawValue: section)!
            switch section {
            case .OrderInfo:
                headerCell.contentLabel?.isHidden = false
                headerCell.contentLabel?.text = order?.status?.name?.localized
                headerCell.contentLabel?.textColor = order?.colorStatus
            case .SKUS:
                headerCell.isHidden = order?.details != nil ? false : true
                headerCell.contentLabel?.isHidden = true
            case .Pickup:
                headerCell.isHidden = order?.from != nil ? false : true
                headerCell.contentLabel?.isHidden = true
            case .Delivery:
                headerCell.isHidden = order?.to != nil ? false : true
                headerCell.contentLabel?.isHidden = true
            }
            return headerCell
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let section:PurchaseOrderSection = PurchaseOrderSection(rawValue: section)!
        switch section {
        case .OrderInfo:
            return FOOTER_HEIGHT
        case .SKUS:
            return order?.details != nil ? FOOTER_HEIGHT : CGFloat.leastNormalMagnitude
        case .Pickup:
            return order?.from != nil ? FOOTER_HEIGHT : CGFloat.leastNormalMagnitude
        case .Delivery:
            return order?.to != nil ? FOOTER_HEIGHT : CGFloat.leastNormalMagnitude
        }
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

