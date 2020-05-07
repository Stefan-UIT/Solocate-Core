//
//  BusinessOrderDetailVC.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/17/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import UIKit
import Foundation
import SideMenu

class BusinessOrderDetailVC: BaseViewController {
    
    enum BusinessOrderSection:Int {
        case OrderInfo = 0
        case Pickup
        case Delivery
        case SKUS
        case Submit
        
        static let count: Int = {
            var max: Int = 0
            while let _ = BusinessOrderSection(rawValue: max) { max += 1 }
            return max
        }()
    }
    
    @IBOutlet weak var tbvContent: UITableView?
    
    
    fileprivate var businessOrderInfo = [BusinessOrderForRow]()
    fileprivate var businessOrderPickupInfo = [BusinessOrderForRow]()
    fileprivate var businessOrderDeliveryInfo = [BusinessOrderForRow]()
    fileprivate var businessOrderItem = [SKUModel]()
    fileprivate var businessOrderItemCellIndentifier = "BusinessOrderItemTableViewCell"
    fileprivate let businessDetailinforCellIndentifier = "BusinessOrderPickerTableViewCell"
    fileprivate let businessConfirmCellIndentifier = "BusinessOrderConfirmTableViewCell"
    fileprivate let headerCellIdentifier = "OrderDetailHeaderCell"
    fileprivate var arrTitleHeader:[String] = []
    
    fileprivate let HEADER_HEIGHT: CGFloat = 60.0
    fileprivate let CELL_HEIGHT: CGFloat = 65.0
    fileprivate let FOOTER_HEIGHT: CGFloat = 10.0
    fileprivate let OPEN_TIME_ROW:Int = 4
    fileprivate let CLOSE_TIME_ROW:Int = 5
    fileprivate let CONSIGNEE_NAME_ROW:Int = 6
    fileprivate let CONSIGNEE_PHONE_ROW:Int = 7
    fileprivate let START_TIME_ROW:Int = 8
    fileprivate let END_TIME_ROW:Int = 9

    private var pickupItem = Address()
    private var deliveryItem = Address()
    private var skuItems:[BusinessOrder.Detail] = []
    private var uomItem = BasicModel()
    
    var order:BusinessOrder?
    var isEditingBO:Bool = false
    var customerList:[UserModel.UserInfo] = []
    var skuList:[SKUModel] = []
    var addressPickUpList:[Address] = []
    var addressDeliveryList:[Address] = []
    var uomList:[UOMModel] = []
    
    var customers:[UserModel.UserInfo]?
    var locations:[Address]?
    var skus:[SKUModel]?
    var uoms:[UOMModel]?
    var zones:[Zone] = []
    var companyId:Int?
    
    var isOrderInfoFilled:Bool = false
    var isEnableSubmit:Bool = false
    var currentIndexPath:IndexPath?
    var currentTag:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVar()
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
        if isEditingBO {
            App().navigationService.updateNavigationBar(.BackOnly, "creating-business-order".localized)
        } else {
            App().navigationService.updateNavigationBar(.BackOnly, "business-order-detail".localized)
        }
        
    }
    
    func addNewSKU() {
        let skuItemModel = SKUModel().createEditSKUItem(skuDataList:skuList, uomDataList: uomList)
        businessOrderItem.append(skuItemModel)
        let skuItem = BusinessOrder.Detail()
        skuItems.append(skuItem)
        tbvContent?.reloadData()
    }
    
    func addZone(isPickup: Bool) {
        var _order:BusinessOrder!
        if order != nil {
            _order = order!
        }
        _order.zone = autoFillZone()
        let itemZone = DropDownModel().addZones(zones)
        let zone = BusinessOrderForRow(title: "zone".localized,
                                       content: Slash(_order.zone?.name),
                                       isEditing: isEditingBO,
                                       style: .Zone,
                                       itemZone,
                                       isRequire: _order.isRequireEdit(_order?.zone?.name, .None))
        
        if isPickup {
            removeZone()
            businessOrderPickupInfo.append(zone)
        } else {
            removeZone()
            businessOrderDeliveryInfo.append(zone)
        }
        tbvContent?.reloadData()
    }
    
    func autoFillZone() -> Zone {
        for index in 0..<zones.count {
            if zones[index].companyId == self.companyId {
                order?.zoneId = zones[index].id
                return zones[index]
            }
        }
        return Zone()
    }
    
    func removeZone() {
        if businessOrderDeliveryInfo.last?.title == "zone".localized {
            businessOrderDeliveryInfo.removeLast()
        } else if businessOrderPickupInfo.last?.title == "zone".localized {
            businessOrderPickupInfo.removeLast()
        }
    }
    
    func setupDataDetailInfoforRows() {
        var _order:BusinessOrder!
        if order != nil {
            _order = order!
        }
        businessOrderInfo.removeAll()
        businessOrderItem.removeAll()
        
        let orderTypeString = _order.orderType.name
        let orderType = BusinessOrderForRow(title: "order-type".localized,
                                            content: Slash(orderTypeString),
                                            isEditing: isEditingBO,
                                            style: .OrderType,
                                            isRequire: _order.isRequireEdit(orderTypeString, .OrderType))
        let itemCustomer = DropDownModel().addCustomers(customerList)
        let customer = BusinessOrderForRow(title: "customer".localized,
                                           content: Slash(_order.customer?.userName),
                                           isEditing: isEditingBO,
                                           style: .Customer,
                                           itemCustomer,
                                           isRequire: _order.isRequireEdit(_order.customer?.userName, .Customer))
        let dueDateFrom = BusinessOrderForRow(title: "due-date-from".localized,
                                          content: Slash(_order.dueDateFrom),
                                          isEditing: isEditingBO,
                                          style: .CalendarStart,
                                          isRequire: _order.isRequireEdit(_order.dueDateFrom, .DueDate))
        let dueDateTo = BusinessOrderForRow(title: "due-date-to".localized,
                                            content: Slash(_order.dueDateTo),
                                            isEditing: isEditingBO,
                                            style: .CalendarEnd,
                                            isRequire: _order.isRequireEdit(_order.dueDateTo, .DueDate))
    
        let codContent = _order.id == BusinessOrderCOD.YES.id ? BusinessOrderCOD.YES.rawValue : BusinessOrderCOD.NO.rawValue
        let cashOnDelivery = BusinessOrderForRow(title: "cash-on-delivery".localized,
                                                 content: Slash(codContent),
                                                 isEditing: isEditingBO,
                                                 style: .COD,
                                                 isRequire: _order.isRequireEdit(codContent, .None))
        
        let remark = BusinessOrderForRow(title: "remark".localized,
                                          content: Slash(_order.remark),
                                          isEditing: isEditingBO,
                                          style: .InputText,
                                          isRequire: _order.isRequireEdit(_order.remark, .None))
        
        businessOrderInfo.append(orderType)
        businessOrderInfo.append(customer)
        businessOrderInfo.append(dueDateFrom)
        businessOrderInfo.append(dueDateTo)
        businessOrderInfo.append(cashOnDelivery)
        businessOrderInfo.append(remark)
        if isEditingBO {
            addNewSKU()
        }
        setupDataAddressAndSKUInRow()
    }
    
    private func setupDataAddressAndSKUInRow() {
        var _order:BusinessOrder!
        if order != nil {
            _order = order!
        }
        
        businessOrderPickupInfo.removeAll()
        businessOrderDeliveryInfo.removeAll()
        // pick-up
        let orderPU = _order.from
        let itemPickUp = DropDownModel().addLocations(addressPickUpList)
        let addressPU = BusinessOrderForRow(title: "Address".localized,
                                            content: Slash(orderPU?.address),
                                            isEditing: isEditingBO,
                                            style: .Address,
                                            itemPickUp,
                                            isRequire: _order.isRequireEdit(orderPU?.address, .Address))
        let floorPU = BusinessOrderForRow(title: "Floor".localized,
                                         content: Slash(orderPU?.floor),
                                         isEditing: false,
                                         style: .InputText,
                                         isRequire: _order.isRequireEdit(orderPU?.floor, .None))
        let apartmentPU = BusinessOrderForRow(title: "Apartment".localized,
                                          content: Slash(orderPU?.apartment),
                                          isEditing: false,
                                          style: .InputText,
                                          isRequire: _order.isRequireEdit(orderPU?.apartment, .None))
        let numberPU = BusinessOrderForRow(title: "number".localized,
                                              content: Slash(orderPU?.number),
                                              isEditing: false,
                                              style: .InputText,
                                              isRequire: _order.isRequireEdit(orderPU?.number, .None))
        let openTimePU = BusinessOrderForRow(title: "open-time".localized,
                                           content: Slash(orderPU?.openTime),
                                           isEditing: isEditingBO,
                                           style: .Time,
                                           isRequire: _order.isRequireEdit(orderPU?.openTime, .OpenTime))
        let closeTimePU = BusinessOrderForRow(title: "close-time".localized,
                                             content: Slash(orderPU?.closeTime),
                                             isEditing: isEditingBO,
                                             style: .Time,
                                             isRequire: _order.isRequireEdit(orderPU?.closeTime, .CloseTime))
        let consigneeNamePU = BusinessOrderForRow(title: "consignee-name".localized,
                                           content: Slash(orderPU?.ctt_name),
                                           isEditing: false,
                                           style: .InputText,
                                           isRequire: _order.isRequireEdit(orderPU?.ctt_name, .None))
        let consigneePhonePU = BusinessOrderForRow(title: "consignee-phone".localized,
                                                  content: Slash(orderPU?.ctt_phone),
                                                  isEditing: false,
                                                  style: .InputText,
                                                  isRequire: _order.isRequireEdit(orderPU?.ctt_phone, .None))
        let startTimePU = BusinessOrderForRow(title: "start-time".localized,
                                              content: Slash(orderPU?.start_time),
                                              isEditing: isEditingBO,
                                              style: .CalendarStart,
                                              isRequire: _order.isRequireEdit(orderPU?.start_time, .StartTime))
        let endTimePU = BusinessOrderForRow(title: "end-time".localized,
                                              content: Slash(orderPU?.end_time),
                                              isEditing: isEditingBO,
                                              style: .CalendarEnd,
                                              isRequire: _order.isRequireEdit(orderPU?.end_time, .EndTime))
        
        businessOrderPickupInfo.append(addressPU)
        businessOrderPickupInfo.append(floorPU)
        businessOrderPickupInfo.append(apartmentPU)
        businessOrderPickupInfo.append(numberPU)
        businessOrderPickupInfo.append(openTimePU)
        businessOrderPickupInfo.append(closeTimePU)
        businessOrderPickupInfo.append(consigneeNamePU)
        businessOrderPickupInfo.append(consigneePhonePU)
        businessOrderPickupInfo.append(startTimePU)
        businessOrderPickupInfo.append(endTimePU)
        
        // delivery
        let orderDV = _order.to
        let itemDelivery = DropDownModel().addLocations(addressDeliveryList)
        let addressDV = BusinessOrderForRow(title: "Address".localized,
                                            content: Slash(orderDV?.address),
                                            isEditing: isEditingBO,
                                            style: .Address,
                                            itemDelivery,
                                            isRequire: _order.isRequireEdit(orderDV?.address, .Address))
        let floorDV = BusinessOrderForRow(title: "Floor".localized,
                                          content: Slash(orderDV?.floor),
                                          isEditing: false,
                                          style: .InputText,
                                          isRequire: _order.isRequireEdit(orderDV?.floor, .None))
        let apartmentDV = BusinessOrderForRow(title: "Apartment".localized,
                                              content: Slash(orderDV?.apartment),
                                              isEditing: false,
                                              style: .InputText,
                                              isRequire: _order.isRequireEdit(orderDV?.apartment, .None))
        let numberDV = BusinessOrderForRow(title: "number".localized,
                                           content: Slash(orderDV?.number),
                                           isEditing: false,
                                           style: .InputText,
                                           isRequire: _order.isRequireEdit(orderDV?.number, .None))
        let openTimeDV = BusinessOrderForRow(title: "open-time".localized,
                                             content: Slash(orderDV?.openTime),
                                             isEditing: isEditingBO,
                                             style: .Time,
                                             isRequire: _order.isRequireEdit(orderDV?.openTime, .OpenTime))
        let closeTimeDV = BusinessOrderForRow(title: "close-time".localized,
                                              content: Slash(orderDV?.closeTime),
                                              isEditing: isEditingBO,
                                              style: .Time,
                                              isRequire: _order.isRequireEdit(orderDV?.closeTime, .CloseTime))
        let consigneeNameDV = BusinessOrderForRow(title: "consignee-name".localized,
                                                  content: Slash(orderDV?.ctt_name),
                                                  isEditing: false,
                                                  style: .InputText,
                                                  isRequire: _order.isRequireEdit(orderDV?.ctt_name, .None))
        let consigneePhoneDV = BusinessOrderForRow(title: "consignee-phone".localized,
                                                   content: Slash(orderDV?.ctt_phone),
                                                   isEditing: false,
                                                   style: .InputText,
                                                   isRequire: _order.isRequireEdit(orderDV?.ctt_phone, .None))
        let startTimeDV = BusinessOrderForRow(title: "start-time".localized,
                                              content: Slash(orderDV?.start_time),
                                              isEditing: isEditingBO,
                                              style: .CalendarStart,
                                              isRequire: _order.isRequireEdit(orderDV?.start_time, .StartTime))
        let endTimeDV = BusinessOrderForRow(title: "end-time".localized,
                                            content: Slash(orderDV?.end_time),
                                            isEditing: isEditingBO,
                                            style: .CalendarEnd,
                                            isRequire: _order.isRequireEdit(orderDV?.end_time, .EndTime))
        businessOrderDeliveryInfo.append(addressDV)
        businessOrderDeliveryInfo.append(floorDV)
        businessOrderDeliveryInfo.append(apartmentDV)
        businessOrderDeliveryInfo.append(numberDV)
        businessOrderDeliveryInfo.append(openTimeDV)
        businessOrderDeliveryInfo.append(closeTimeDV)
        businessOrderDeliveryInfo.append(consigneeNameDV)
        businessOrderDeliveryInfo.append(consigneePhoneDV)
        businessOrderDeliveryInfo.append(startTimeDV)
        businessOrderDeliveryInfo.append(endTimeDV)
        
        //Zone
        let isPickup = _order.typeID == OrderType.pickup.rawValue ? true : false
        self.addZone(isPickup: isPickup)
        
        //item
        tbvContent?.reloadData()
        if !isEditingBO {
            guard let details = _order?.details else { return }
            if details.count != 0 {
                for (_,detail) in _order.details!.enumerated() {
                    let skuItem = SKUModel().createSKUItem(skuContent: Slash(detail.name),
                                                           skuDataList: skuList,
                                                           uomDataList: uomList,
                                                           qtyContent: IntSlash(detail.pivot?.qty),
                                                           uomContent: Slash(detail.pivot?.uom?.name),
                                                           batchContent: Slash(detail.pivot?.batch_id),
                                                           barcodeContent: Slash(detail.pivot?.bcd))
                    businessOrderItem.append(skuItem)
                }
            }
            tbvContent?.reloadData()
        }
    }
    
    override func updateUI()  {
        super.updateUI()
        tbvContent?.allowsSelection = isEditingBO
        if isEditingBO {
            setupDataList()
        } else {
            fetchData(showLoading: true)
        }
        
        tbvContent?.reloadData()
    }
    
    func initVar() {
        arrTitleHeader = ["order-info".localized,
                          "pickup".localized,
                          "Delivery".localized,
                          "items".localized,
                          "submit".localized]
    }
    
}

extension BusinessOrderDetailVC: DMSNavigationServiceDelegate {
    func didSelectedBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableView
extension BusinessOrderDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSection = isEditingBO ? arrTitleHeader.count : (arrTitleHeader.count - 1)
        if !isOrderInfoFilled && isEditingBO {
            numberOfSection = 1
        }
        return numberOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section:BusinessOrderSection = BusinessOrderSection(rawValue: section)!
        switch section {
        case .OrderInfo:
            return businessOrderInfo.count
        case .Pickup:
            return businessOrderPickupInfo.count
        case .Delivery:
            return businessOrderDeliveryInfo.count
        case .SKUS:
            return businessOrderItem.count
        case .Submit:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section:BusinessOrderSection = BusinessOrderSection(rawValue: section)!
        switch section {
        case .OrderInfo:
            return HEADER_HEIGHT
        case .Pickup:
            return HEADER_HEIGHT
        case .Delivery:
            return HEADER_HEIGHT
        case .SKUS:
            return HEADER_HEIGHT
        case .Submit:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as? OrderDetailTableViewCell{
            headerCell.nameLabel?.text = arrTitleHeader[section]
            headerCell.delegate = self
            headerCell.btnStatus?.isHidden = true
            headerCell.btnEdit?.isHidden = true
            let headerSection:BusinessOrderSection = BusinessOrderSection(rawValue: section)!
            switch headerSection {
            case .OrderInfo:
                headerCell.btnStatus?.isHidden = isEditingBO ? true : false
                headerCell.btnStatus?.setTitle(order?.statusName.localized, for: .normal)
                headerCell.btnStatus?.setTitleColor(order?.colorStatus, for: .normal)
                headerCell.contentLabel?.isHidden = true
            case .Pickup:
                headerCell.contentLabel?.isHidden = true
            case .Delivery:
                headerCell.contentLabel?.isHidden = true
            case .SKUS:
                headerCell.btnEdit?.isHidden = !isEditingBO
                headerCell.btnEdit?.tag = section
                headerCell.contentLabel?.isHidden = true
            case .Submit:
                return headerCell
            }
            let headerView = UIView()
            headerView.addSubview(headerCell)
            headerCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: HEADER_HEIGHT)
            return headerView;
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let section:BusinessOrderSection = BusinessOrderSection(rawValue: section)!
        switch section {
        case .OrderInfo:
            return FOOTER_HEIGHT
        case .Pickup:
            return FOOTER_HEIGHT
        case .Delivery:
            return FOOTER_HEIGHT
        case .SKUS:
            return FOOTER_HEIGHT
        case .Submit:
            return FOOTER_HEIGHT
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view:UIView = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section:BusinessOrderSection = BusinessOrderSection(rawValue: indexPath.section)!
        switch section {
        case .OrderInfo:
            return businessOrderInfoCell(items: businessOrderInfo, tableView, indexPath)
        case .Pickup:
            return businessOrderInfoCell(items: businessOrderPickupInfo, tableView, indexPath)
        case .Delivery:
            return businessOrderInfoCell(items: businessOrderDeliveryInfo, tableView, indexPath)
        case .SKUS:
            return businessOrderItemInfo(items: businessOrderItem, tableView, indexPath)
        case .Submit:
            return businessOrderConfirmInfoCell(tableView, indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section:BusinessOrderSection = BusinessOrderSection(rawValue: indexPath.section)!
        switch section {
        case .Submit:
            if !isEnableSubmit {
                return
            }
            guard let _order = order else { return }
            self.submitCreateBO(order: _order)
        @unknown default:
            return tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let isCanEdit = self.isEditingBO && skuItems.count > 1
        return isCanEdit
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            businessOrderItem.remove(at: indexPath.row)
            skuItems.remove(at: indexPath.row)
            tbvContent?.deleteRows(at: [indexPath], with: .bottom )
        }
    }
    
    func businessOrderInfoCell(items:[BusinessOrderForRow],_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: businessDetailinforCellIndentifier, for: indexPath) as! BusinessOrderPickerTableViewCell
        cell.orderDetailItem = item
        cell.delegate = self
        cell.indexPath = indexPath
        cell.selectionStyle = .none
        return cell
    }
    
    func businessOrderItemInfo(items: [SKUModel],_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: businessOrderItemCellIndentifier, for: indexPath) as! BusinessOrderItemTableViewCell
        cell.isEditingBO = self.isEditingBO
        cell.item = item
        cell.indexPath = indexPath
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
        
    }
    
    func businessOrderConfirmInfoCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: businessConfirmCellIndentifier, for: indexPath) as! BusinessOrderConfirmTableViewCell
        cell.submitView.backgroundColor = isEnableSubmit ? AppColor.greenColor : AppColor.grayColor
        cell.submitView.textColor = isEnableSubmit ? AppColor.white : AppColor.black
        cell.selectionStyle = .none
        return cell
    }
    
}

extension BusinessOrderDetailVC: BusinessOrderItemTableViewCellDelegate {
    func didSelectedDopdown(_ cell: BusinessOrderItemTableViewCell, _ btn: UIButton, style: DropDownType, _ itemDropDown: DropDownModel?, _ titleContent: String, tag: Int, indexPath: IndexPath) {
        self.currentIndexPath = indexPath
        self.currentTag = tag
        let vc = DropDownViewController()
        vc.titleContent = titleContent
        vc.dropDownType = style
        vc.itemDropDown = itemDropDown
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        App().window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
    func didSelectShowBarcode() {
        self.tbvContent?.reloadData()
    }
    
}

//MARK:
extension BusinessOrderDetailVC: BusinessOrderPickerTableViewCellDelegate {
    func didSelectedDopdown(_ cell: BusinessOrderPickerTableViewCell, _ btn: UIButton, style: DropDownType, indexPath: IndexPath, _ item: DropDownModel, _ titleContent: String) {
        self.currentIndexPath = indexPath
        let vc = DropDownViewController()
        vc.titleContent = titleContent
        vc.dropDownType = style
        vc.itemDropDown = item
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        App().window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
}

extension BusinessOrderDetailVC: DropDownViewControllerDelegate {
    
    func didSelectItem(item: DropDownModel) {
        editItemInRow(item)
    }
    
    
}

extension BusinessOrderDetailVC: OrderDetailTableViewCellDelegate {
    func didSelectedDopdown(_ cell: OrderDetailTableViewCell, _ btn: UIButton) {
        //
    }
    
    func didSelectEdit(_ cell: OrderDetailTableViewCell, _ btn: UIButton) {
        self.addNewSKU()
    }
    
    func didSelectGo(_ cell: OrderDetailTableViewCell, _ btn: UIButton) {
        //
    }
    
    func didEnterPalletsQuantityTextField(_ cell: OrderDetailTableViewCell, value: String, detail: Order.Detail) {
        //
    }
    
    func didEnterCartonsQuantityTextField(_ cell: OrderDetailTableViewCell, value: String, detail: Order.Detail) {
        //
    }
    
    
}

//MARK: API
extension BusinessOrderDetailVC {
    func fetchData(showLoading:Bool = false)  {
        getBusinessOrderDetail()
    }
    
    private func getBusinessOrderDetail(isFetch:Bool = false) {
        if ReachabilityManager.isNetworkAvailable {
            guard let _orderID = order?.id else { return }
            if !isFetch {
                showLoadingIndicator()
            }
            SERVICES().API.getBusinessOrderDetail(orderId: "\(_orderID)") {[weak self] (result) in
                self?.dismissLoadingIndicator()
                switch result{
                case .object(let object):
                    guard let _orderDetail = object.data else { return }
                    self?.order = _orderDetail
                    self?.initVar()
                    self?.setupDataDetailInfoforRows()
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
    
    func setLocationToOrder() {
        guard let _order = order else { return }
        _order.customerLocationId = (_order.isPickUpType) ? String(pickupItem.id) : String(deliveryItem.id)
        _order.wareHouseId = (_order.isPickUpType) ? String(deliveryItem.id) : String(pickupItem.id)
    }
    
    private func submitCreateBO(order:BusinessOrder) {
        setLocationToOrder()
        self.showLoadingIndicator()
        SERVICES().API.createBusinessOrder(order: order) {[weak self] (result) in
            switch result {
            case .object(_):
                self?.dismissLoadingIndicator()
                self?.showAlertView("uploaded-successful".localized, completionHandler: { (action) in
                    self?.navigationController?.popViewController(animated: true)
                })
            case .error(let error):
                self?.dismissLoadingIndicator()
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    private func getCustomerList() {
        self.showLoadingIndicator()
        SERVICES().API.getCustomerList() {[weak self] (result) in
            switch result {
            case .object(let data):
                self?.customers = data.data
                self?.customerList = data.data ?? []
                self?.getLocationsList()
            case .error(let error):
                self?.dismissLoadingIndicator()
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    private func getLocationsList() {
        SERVICES().API.getLocationsList() {[weak self] (result) in
            switch result {
            case .object(let data):
                self?.locations = data.data
                self?.getSKUList()
            case .error(let error):
                self?.dismissLoadingIndicator()
                self?.showAlertView(error.getMessage())
            }
            
        }
    }
    
    private func getSKUList() {
        SERVICES().API.getSKUList() {[weak self] (result) in
            switch result {
            case .object(let data):
                self?.skus = data.data
                self?.getUOMList()
            case .error(let error):
                self?.dismissLoadingIndicator()
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    private func getUOMList() {
        SERVICES().API.getUOMList() {[weak self] (result) in
            switch result {
            case .object(let data):
                self?.uoms = data.data
                self?.getZoneList()
            case .error(let error):
                self?.dismissLoadingIndicator()
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    private func getZoneList() {
        SERVICES().API.getZoneList() {[weak self] (result) in
            switch result {
            case .object(let data):
                guard let _zones = data.data else { return }
                self?.zones = _zones
                self?.setupDataDetailInfoforRows()
                self?.dismissLoadingIndicator()
            case .error(let error):
                self?.dismissLoadingIndicator()
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
}

// MARK: - FUNCTION FOR EDIT BUSINESS ORDER

extension BusinessOrderDetailVC {
    
    func setupDataList() {
        self.getCustomerList()
    }
    
    func setupViewAfterEdit() {
//        checkOrderTypeRow()
        checkCustomerRow()
        checkOrderInfoFilled()
        checkRequire()
    }
    
    func renewAddressSKUData() {
        businessOrderPickupInfo.removeAll()
        businessOrderDeliveryInfo.removeAll()
        order?.from = nil
        order?.to = nil
        setupDataAddressAndSKUInRow()
    }
    
    func checkOrderTypeRow() {
        if order?.typeID != 0 && order?.typeID != nil {
            customerList = []
            guard let _customers = customers else { return }
            customerList = _customers
            let rowCustomer = BusinessOrderInfoRow.CUSTOMER.rawValue
            let item = DropDownModel().addCustomers(customerList)
            businessOrderInfo[rowCustomer].data = item
        }
    }
    
    func updateCustomersDropDownUI() {
        guard let _customers = customers else { return }
        customerList = _customers
        let rowCustomer = BusinessOrderInfoRow.CUSTOMER.rawValue
        let item = DropDownModel().addCustomers(customerList)
        businessOrderInfo[rowCustomer].data = item
        // comment
    }
    
    func checkCustomerRow() {
        guard let _locationsList = locations, let _typeID = order?.typeID else { return }
        
        var tempAddressPickUP:[Address] = []
        var tempAddressDelivery:[Address] = []
        let orderType:OrderType = OrderType(rawValue: _typeID)!
        switch orderType {
        case .delivery:
            for (_,location) in _locationsList.enumerated() {
                for index in 0..<(location.types?.count ?? 0) {
                    if location.types?[index].code == BusinessOrderLocationType.Warehouse.rawValue || location.types?[index].code == BusinessOrderLocationType.Pickup.rawValue {
                        if tempAddressPickUP.last?.id != location.id {
                            tempAddressPickUP.append(location)
                        }
                    } else {
                        if tempAddressDelivery.last?.id != location.id {
                            tempAddressDelivery.append(location)
                        }
                    }
                }
            }
            let rowCustomer = BusinessOrderAddressInfoRow.ADDRESS.rawValue
            addressDeliveryList = tempAddressDelivery
            addressPickUpList = tempAddressPickUP
            let itemDropDownDelivery  = DropDownModel().addLocations(addressDeliveryList)
            let itemDropDownPickUp  = DropDownModel().addLocations(addressPickUpList)
            businessOrderDeliveryInfo[rowCustomer].data = itemDropDownDelivery
            businessOrderPickupInfo[rowCustomer].data = itemDropDownPickUp
        case .pickup:
            for (_,location) in _locationsList.enumerated() {
                for index in 0..<(location.types?.count ?? 0) {
                    if location.types?[index].code == BusinessOrderLocationType.Warehouse.rawValue {
                        if tempAddressDelivery.last?.id != location.id {
                            tempAddressDelivery.append(location)
                        }
                    } else {
                        if tempAddressPickUP.last?.id != location.id {
                            tempAddressPickUP.append(location)
                        }
                    }
                }
            }
            let rowCustomer = BusinessOrderAddressInfoRow.ADDRESS.rawValue
            addressDeliveryList = tempAddressDelivery
            addressPickUpList = tempAddressPickUP
            let itemDropDownDelivery  = DropDownModel().addLocations(addressDeliveryList)
            let itemDropDownPickUp  = DropDownModel().addLocations(addressPickUpList)
            businessOrderDeliveryInfo[rowCustomer].data = itemDropDownDelivery
            businessOrderPickupInfo[rowCustomer].data = itemDropDownPickUp
        case .empty:
            return
        }

        guard let _skus = skus , let _uoms = uoms , let orderCustomers = customers else  { return }
        
        skuList = []
        uomList = []
        var tempSKUList:[SKUModel] = []
        
        var listIDCustomers:[Int] = []
        for (_,orderCustomer) in orderCustomers.enumerated() {
            listIDCustomers.append(orderCustomer.id)
        }
        
        for (_, sku) in _skus.enumerated() {
            for index in 0..<(sku.customers?.count ?? 0){
                if listIDCustomers.contains(sku.customers?[index].id ?? 0) {
                    tempSKUList.append(sku)
                    break
                }
            }
        }
        // This code add SKU/UOM Datalist for First businessOrderItem because we create null data in first time access BODetailVC
        businessOrderItem.first?.skuDataList = tempSKUList
        businessOrderItem.first?.uomDataList = _uoms
        //
        skuList = tempSKUList
        uomList = _uoms
    }
    
    func checkOrderInfoFilled() {
        isOrderInfoFilled = order?.typeID != nil && order?.customer != nil && (order?.dueDateFrom != nil || order?.dueDateFrom?.isEmpty == false) &&  (order?.dueDateTo?.isEmpty == false || order?.dueDateTo != nil)
        tbvContent?.reloadData()
    }
    
    func checkRequire() {
        var isQualitySubmit = false
        for index in 0..<(order?.details?.count ?? 0){
            isQualitySubmit = order?.details?[index].pivot?.uom != nil && order?.details?[index].pivot?.qty != nil && order?.details?[index].pivot?.qty != 0
        }
        
        isEnableSubmit = order?.typeID != nil && order?.customer != nil && (order?.dueDateFrom != nil || order?.dueDateFrom?.isEmpty == false) &&  (order?.dueDateTo?.isEmpty == false || order?.dueDateTo != nil) && order?.from != nil && order?.to != nil && order?.zoneId != nil && order?.details != nil && order?.to?.start_time != nil && order?.to?.end_time != nil && order?.to?.openTime != nil && order?.to?.closeTime != nil && order?.from?.start_time != nil && order?.from?.end_time != nil && order?.from?.openTime != nil && order?.from?.closeTime != nil && isQualitySubmit
        
        tbvContent?.reloadData()
    }
    
    func editItemInRow(_ item:DropDownModel) {
        guard let _indexPath = currentIndexPath else { return }
        let section = _indexPath.section
        let row = _indexPath.row
        let sectionInfo:BusinessOrderSection = BusinessOrderSection(rawValue: section)!
        switch sectionInfo {
        case .OrderInfo:
            editOrderInfo(row: row, item: item)
        case .Pickup:
            editOrderPickupInfo(row: row, item: item)
        case .Delivery:
            editOrderDeliveryInfo(row: row, item: item)
        case .SKUS:
            editOrderSKUInfo(row: row, index: (currentTag ?? 0), item: item)
        case .Submit:
            break
        }
        
        tbvContent?.reloadData()
    }
    
    func editOrderInfo(row:Int, item:DropDownModel) {
        var textContent = item.result
        let infoRow:BusinessOrderInfoRow = BusinessOrderInfoRow(rawValue: row)!
        switch infoRow {
        case .ORDER_TYPE:
            guard let _orderType = item.result, let _order = order else { return }
            order?.typeID = _orderType == BusinessOrderType.Pickup.rawValue ? BusinessOrderType.Pickup.typeId : BusinessOrderType.Delivery.typeId
            order?.orderType = OrderType(rawValue: _order.typeID)!
            textContent = order!.orderType.name
            let isPickup = _orderType == BusinessOrderType.Pickup.rawValue ? true : false
            renewAddressSKUData()
            addZone(isPickup: isPickup)
        case .CUSTOMER:
            guard let _customer = item.customers?.first else { return }
            order?.customer = _customer
            order?.customerId = String(_customer.id)
            order?.customerLocationId = String(_customer.id)
            textContent = _customer.userName
            self.companyId = _customer.companyID
            renewAddressSKUData()
        case .DUE_DATE_FROM:
            guard let _date = item.dateStart else { return }
            order?.dueDateFrom = DateFormatter.displayDateTimeUSWithSecond.string(from: _date)
            textContent = order?.dueDateFrom
            let data = DropDownModel()
            data.dateStart = order?.dueDateFrom?.dateUS
            data.dateEnd = order?.dueDateTo?.dateUS
            businessOrderInfo[row].data = data
            businessOrderInfo[row+1].data = data
            
        case .DUE_DATE_TO:
            guard let _date = item.dateEnd else { return }
            order?.dueDateTo = DateFormatter.displayDateTimeUSWithSecond.string(from: _date)
            textContent = order?.dueDateTo
            let data = DropDownModel()
            data.dateStart = order?.dueDateFrom?.dateUS
            data.dateEnd = order?.dueDateTo?.dateUS
            businessOrderInfo[row].data = data
            businessOrderInfo[row-1].data = data
        case .COD:
            order?.cod = textContent == BusinessOrderCOD.YES.rawValue ? BusinessOrderCOD.YES.id : BusinessOrderCOD.NO.id
        case .REMARK:
            order?.remark = textContent
        }
        businessOrderInfo[row].content = Slash(textContent)
        setupViewAfterEdit()
        tbvContent?.reloadData()
    }
    
    func autoFillAddressData(_ address: Address, isPickup: Bool) {
        let FLOOR_ROW:Int = 1
        let APARTMENT_ROW:Int = 2
        let NUMBER_ROW:Int = 3
        let OPEN_ROW:Int = 4
        let CLOSE_ROW:Int = 5
        let CTT_NAME_ROW:Int = 6
        let CTT_PHONE_ROW:Int = 7
        
        if isPickup {
            businessOrderPickupInfo[FLOOR_ROW].content = Slash(address.floor)
            businessOrderPickupInfo[APARTMENT_ROW].content = Slash(address.apartment)
            businessOrderPickupInfo[NUMBER_ROW].content = Slash(address.number)
            businessOrderPickupInfo[OPEN_ROW].content = Slash(address.openTime)
            businessOrderPickupInfo[CLOSE_ROW].content = Slash(address.closeTime)
            businessOrderPickupInfo[CTT_NAME_ROW].content = Slash(address.ctt_name)
            businessOrderPickupInfo[CTT_PHONE_ROW].content = Slash(address.ctt_phone)
        } else {
            businessOrderDeliveryInfo[FLOOR_ROW].content = Slash(address.floor)
            businessOrderDeliveryInfo[APARTMENT_ROW].content = Slash(address.apartment)
            businessOrderDeliveryInfo[NUMBER_ROW].content = Slash(address.number)
            businessOrderDeliveryInfo[OPEN_ROW].content = Slash(address.openTime)
            businessOrderDeliveryInfo[CLOSE_ROW].content = Slash(address.closeTime)
            businessOrderDeliveryInfo[CTT_NAME_ROW].content = Slash(address.ctt_name)
            businessOrderDeliveryInfo[CTT_PHONE_ROW].content = Slash(address.ctt_phone)
        }
    }
    
    func editOrderPickupInfo(row:Int, item:DropDownModel?) {
        let infoRow:BusinessOrderAddressInfoRow = BusinessOrderAddressInfoRow(rawValue: row)!
        var textContent = item?.result
        switch infoRow {
        case .ADDRESS:
            guard let _address = item?.locations?.first, let _customers = _address.customers else { return }
            pickupItem.id = _address.id
            pickupItem.address = _address.address
            pickupItem.floor = _address.floor
            pickupItem.apartment = _address.apartment
            pickupItem.number = _address.number
            pickupItem.ctt_name = _address.ctt_name
            pickupItem.ctt_phone = _address.phone
            pickupItem.lattd = _address.lattd
            pickupItem.lngtd = _address.lngtd
            
            for (_,customer) in _customers.enumerated() {
                if customer.pivot?.customerId!.toString() == order?.customerId {
                    pickupItem.openTime = customer.pivot?.openTime
                    pickupItem.closeTime = customer.pivot?.closeTime
                    pickupItem.ctt_name = customer.pivot?.consigneeName
                    pickupItem.ctt_phone = customer.pivot?.consigneePhone
                    break
                } else {
                    pickupItem.openTime = ""
                    pickupItem.closeTime = ""
                    pickupItem.ctt_name = ""
                    pickupItem.ctt_phone = ""
                }
            }
            
            autoFillAddressData(_address, isPickup: true)
            textContent = pickupItem.address
        case .FLOOR:
            pickupItem.floor = textContent
        case .APARTMENT:
            pickupItem.apartment = textContent
        case .NUMBER:
            pickupItem.number = textContent
        case .OPEN_TIME:
            pickupItem.openTime = textContent
        case .CLOSE_TIME:
            pickupItem.closeTime = textContent
        case .CONSIGNEE_NAME:
            pickupItem.ctt_name = textContent
        case .CONSIGNEE_PHONE:
            pickupItem.ctt_phone = textContent
        case .START_TIME:
            guard let _date = item?.dateStart else { return }
            pickupItem.start_time = DateFormatter.displayDateTimeUSWithSecond.string(from: _date)
            textContent = pickupItem.start_time
            let data = DropDownModel()
            data.dateStart = pickupItem.start_time?.dateUS
            data.dateEnd = pickupItem.end_time?.dateUS
            businessOrderPickupInfo[START_TIME_ROW].data = data
            businessOrderPickupInfo[END_TIME_ROW].data = data
        case .END_TIME:
            guard let _date = item?.dateEnd else { return }
            pickupItem.end_time = DateFormatter.displayDateTimeUSWithSecond.string(from: _date)
            textContent = pickupItem.end_time
            let data = DropDownModel()
            data.dateStart = pickupItem.start_time?.dateUS
            data.dateEnd = pickupItem.end_time?.dateUS
            businessOrderPickupInfo[START_TIME_ROW].data = data
            businessOrderPickupInfo[END_TIME_ROW].data = data
        case .ZONE:
            guard let _zone = item?.zones?.first else { return }
            order?.zoneId = _zone.id
            textContent = _zone.name
        }
        businessOrderPickupInfo[row].content = Slash(textContent)
        businessOrderPickupInfo[CONSIGNEE_NAME_ROW].content = Slash(pickupItem.ctt_name)
        businessOrderPickupInfo[CONSIGNEE_PHONE_ROW].content = Slash(pickupItem.phone)
        businessOrderPickupInfo[OPEN_TIME_ROW].content = Slash(pickupItem.openTime)
        businessOrderPickupInfo[CLOSE_TIME_ROW].content = Slash(pickupItem.closeTime)
        order?.from = pickupItem
//        if order?.typeID == OrderType.pickup.rawValue {
//            order?.customerLocationId = String(pickupItem.id)
//        } else {
//            order?.wareHouseId = String(pickupItem.id)
//        }
        setupViewAfterEdit()
    }
    
    func editOrderDeliveryInfo(row:Int,item:DropDownModel?) {
        let infoRow:BusinessOrderAddressInfoRow = BusinessOrderAddressInfoRow(rawValue: row)!
        var textContent = item?.result
        switch infoRow {
        case .ADDRESS:
            guard let _address = item?.locations?.first, let _customers = _address.customers else { return }
            deliveryItem.id = _address.id
            deliveryItem.address = _address.address
            deliveryItem.floor = _address.floor
            deliveryItem.apartment = _address.apartment
            deliveryItem.number = _address.number
            deliveryItem.lattd = _address.lattd
            deliveryItem.lngtd = _address.lngtd
            
            for (_,customer) in _customers.enumerated() {
                if customer.pivot?.customerId!.toString() == order?.customerId {
                    deliveryItem.openTime = customer.pivot?.openTime
                    deliveryItem.closeTime = customer.pivot?.closeTime
                    deliveryItem.ctt_name = customer.pivot?.consigneeName
                    deliveryItem.ctt_phone = customer.pivot?.consigneePhone
                    break
                } else {
                    deliveryItem.openTime = ""
                    deliveryItem.closeTime = ""
                    deliveryItem.ctt_name = ""
                    deliveryItem.ctt_phone = ""
                }
            }
            
            autoFillAddressData(_address, isPickup: false)
            textContent = deliveryItem.address
        case .FLOOR:
            deliveryItem.floor = textContent
        case .APARTMENT:
            deliveryItem.apartment = textContent
        case .NUMBER:
            deliveryItem.number = textContent
        case .OPEN_TIME:
            deliveryItem.openTime = textContent
        case .CLOSE_TIME:
            deliveryItem.closeTime = textContent
        case .CONSIGNEE_NAME:
            deliveryItem.ctt_name = textContent
        case .CONSIGNEE_PHONE:
            deliveryItem.ctt_phone = textContent
        case .START_TIME:
            guard let _date = item?.dateStart else { return }
            deliveryItem.start_time = DateFormatter.displayDateTimeUSWithSecond.string(from: _date)
            textContent = deliveryItem.start_time
            let data = DropDownModel()
            data.dateStart = pickupItem.start_time?.dateUS
            data.dateEnd = pickupItem.end_time?.dateUS
            businessOrderDeliveryInfo[START_TIME_ROW].data = data
            businessOrderDeliveryInfo[END_TIME_ROW].data = data
        case .END_TIME:
            guard let _date = item?.dateEnd else { return }
            deliveryItem.end_time = DateFormatter.displayDateTimeUSWithSecond.string(from: _date)
            textContent = deliveryItem.end_time
            let data = DropDownModel()
            data.dateStart = pickupItem.start_time?.dateUS
            data.dateEnd = pickupItem.end_time?.dateUS
            businessOrderDeliveryInfo[START_TIME_ROW].data = data
            businessOrderDeliveryInfo[END_TIME_ROW].data = data
        case .ZONE:
            guard let _zone = item?.zones?.first else { return }
            order?.zoneId = _zone.id
            textContent = _zone.name
        }
        businessOrderDeliveryInfo[row].content = Slash(textContent)
        businessOrderDeliveryInfo[CONSIGNEE_NAME_ROW].content = Slash(deliveryItem.ctt_name)
        businessOrderDeliveryInfo[CONSIGNEE_PHONE_ROW].content = Slash(deliveryItem.phone)
        businessOrderDeliveryInfo[OPEN_TIME_ROW].content = Slash(deliveryItem.openTime)
        businessOrderDeliveryInfo[CLOSE_TIME_ROW].content = Slash(deliveryItem.closeTime)
        order?.to = deliveryItem
        order?.customerLocationId = String(deliveryItem.id)
//        if order?.typeID == OrderType.delivery.rawValue {
//            order?.customerLocationId = String(deliveryItem.id)
//        } else {
//            order?.wareHouseId = String(deliveryItem.id)
//        }
        setupViewAfterEdit()
    }
    
    func getLocations() {
        
    }
    
    func editOrderSKUInfo(row: Int,index: Int, item:DropDownModel?) {
        let index:BusinessOrderSKUInfoRow = BusinessOrderSKUInfoRow(rawValue: index)!
        var textContent = item?.result
        if skuItems[row].pivot == nil {
            let json:[String:Any] = ["qty":0, "uom":["id":0,
                                                     "name":"",
                                                     "code":""],
                                     "batch_id":""]
            let pivot = BusinessOrder.Detail.Pivot(JSON: json)
            skuItems[row].pivot = pivot
        }
        switch index {
        case .SKU:
            guard let _sku = item?.skus?.first else { return }
            skuItems[row] = _sku
            
            // reset Quantity
            let json:[String:Any] = ["qty":0]
            let pivot = BusinessOrder.Detail.Pivot(JSON: json)
            skuItems[row].pivot = pivot
            businessOrderItem[row].itemContent[BusinessOrderSKUInfoRow.QUANTITY.rawValue] = IntSlash(skuItems[row].pivot?.qty)
            
            if _sku.uom != nil {
                let json:[String:Any] = ["uom":["id":(_sku.uom?.id ?? 0),
                                                "name":(_sku.uom?.name ?? ""),
                                                         "code":(_sku.uom?.code ?? "")]]
                let pivot = BusinessOrder.Detail.Pivot(JSON: json)
                skuItems[row].pivot = pivot
                businessOrderItem[row].itemContent[BusinessOrderSKUInfoRow.UOM.rawValue] = Slash(skuItems[row].pivot?.uom?.name)
            }
            businessOrderItem[row].barcodeBool = _sku.barcodeBool
            textContent = _sku.skuName
            tbvContent?.reloadData()
        case .QUANTITY:
            skuItems[row].pivot?.qty = Int(textContent ?? "") ?? 0
        case .UOM: break
//            guard let _uom = item?.uoms?.first else { return }
//            skuItems[row].pivot?.uom = _uom
//            textContent = skuItems[row].pivot?.uom?.name ?? ""
        case .BATCH_ID:
            skuItems[row].pivot?.batch_id = textContent
        case .BARCODE:
            skuItems[row].bcd = textContent
        }
        businessOrderItem[row].itemContent[currentTag ?? 0]  = Slash(textContent)
        order?.details = skuItems
        skuItems[row].skuId = String(skuItems[row].id)
        skuItems[row].batchId = skuItems[row].pivot?.batch_id ?? ""
        skuItems[row].unitId = skuItems[row].pivot?.uom?.id ?? -1
        skuItems[row].qty = skuItems[row].pivot?.qty ?? -1
        skuItems[row].bcd = String(skuItems[row].bcd ?? "")
        setupViewAfterEdit()
    }
    
}


