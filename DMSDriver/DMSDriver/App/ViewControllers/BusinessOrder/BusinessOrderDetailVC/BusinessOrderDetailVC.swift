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
    

    private var pickupItem = Address()
    private var deliveryItem = Address()
    private var skuItems:[BusinessOrder.Detail] = []
    private var uomItem = BasicModel()
    
    var dateStringFilter = Date().toString()
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
    
    var isOrderInfoFilled:Bool = false
    var currentIndexPath:IndexPath?
    var currentTag:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
//        fetchData(showLoading: true)
        initVar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        fetchData(showLoading: true)
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
        let itemZone = DropDownModel().addZones(zones)
        let zone = BusinessOrderForRow(title: "zone".localized,
                                       content: Slash(_order.zone?.name),
                                       isEditing: isEditingBO,
                                       style: .Zone,
                                       itemZone,
                                       isRequire: _order.isRequireEdit(_order?.zone?.name, .Zone))
        
        if isPickup {
            removeZone()
            businessOrderPickupInfo.append(zone)
        } else {
            removeZone()
            businessOrderDeliveryInfo.append(zone)
        }
        tbvContent?.reloadData()
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
        
        let orderTypeString = _order.orderType.name
        let orderType = BusinessOrderForRow(title: "order-type".localized,
                                            content: Slash(orderTypeString),
                                            isEditing: isEditingBO,
                                            style: .OrderType,
                                            isRequire: _order.isRequireEdit(orderTypeString, .OrderType))
        let itemCustomer = DropDownModel().addCustomers(customerList)
        let customer = BusinessOrderForRow(title: "customer".localized,
                                           content: Slash(_order.customer_name),
                                           isEditing: isEditingBO,
                                           style: .Customer,
                                           itemCustomer,
                                           isRequire: _order.isRequireEdit(_order.customer_name, .Customer))
        let dueDateFrom = BusinessOrderForRow(title: "due-date-from".localized,
                                          content: Slash(_order.dueDateFrom),
                                          isEditing: isEditingBO,
                                          style: .Calendar,
                                          isRequire: _order.isRequireEdit(_order.dueDateFrom, .DueDate))
        let dueDateTo = BusinessOrderForRow(title: "due-date-to".localized,
                                            content: Slash(_order.dueDateTo),
                                            isEditing: isEditingBO,
                                            style: .Calendar,
                                            isRequire: _order.isRequireEdit(_order.dueDateTo, .DueDate))
        let remark = BusinessOrderForRow(title: "remark".localized,
                                          content: Slash(_order.remark),
                                          isEditing: isEditingBO,
                                          style: .InputText,
                                          isRequire: _order.isRequireEdit(_order.remark, .None))
        
        businessOrderInfo.append(orderType)
        businessOrderInfo.append(customer)
        businessOrderInfo.append(dueDateFrom)
        businessOrderInfo.append(dueDateTo)
        businessOrderInfo.append(remark)
        setupDataAddressAndSKUInRow()
    }
    
    private func setupDataAddressAndSKUInRow() {
        var _order:BusinessOrder!
        if order != nil {
            _order = order!
        }
        
        businessOrderPickupInfo.removeAll()
        businessOrderDeliveryInfo.removeAll()
        businessOrderItem.removeAll()
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
                                         isEditing: isEditingBO,
                                         style: .InputText,
                                         isRequire: _order.isRequireEdit(orderPU?.floor, .None))
        let apartmentPU = BusinessOrderForRow(title: "Apartment".localized,
                                          content: Slash(orderPU?.apartment),
                                          isEditing: isEditingBO,
                                          style: .InputText,
                                          isRequire: _order.isRequireEdit(orderPU?.apartment, .None))
        let numberPU = BusinessOrderForRow(title: "number".localized,
                                              content: Slash(orderPU?.number),
                                              isEditing: isEditingBO,
                                              style: .InputText,
                                              isRequire: _order.isRequireEdit(orderPU?.number, .None))
        let openTimePU = BusinessOrderForRow(title: "open-time".localized,
                                           content: Slash(orderPU?.openTime),
                                           isEditing: isEditingBO,
                                           style: .Time,
                                           isRequire: _order.isRequireEdit(orderPU?.openTime, .None))
        let closeTimePU = BusinessOrderForRow(title: "close-time".localized,
                                             content: Slash(orderPU?.closeTime),
                                             isEditing: isEditingBO,
                                             style: .Time,
                                             isRequire: _order.isRequireEdit(orderPU?.closeTime, .None))
        let consigneeNamePU = BusinessOrderForRow(title: "consignee-name".localized,
                                           content: Slash(orderPU?.ctt_name),
                                           isEditing: isEditingBO,
                                           style: .InputText,
                                           isRequire: _order.isRequireEdit(orderPU?.ctt_name, .None))
        let consigneePhonePU = BusinessOrderForRow(title: "consignee-phone".localized,
                                                  content: Slash(orderPU?.ctt_phone),
                                                  isEditing: isEditingBO,
                                                  style: .InputText,
                                                  isRequire: _order.isRequireEdit(orderPU?.ctt_phone, .None))
        
        businessOrderPickupInfo.append(addressPU)
        businessOrderPickupInfo.append(floorPU)
        businessOrderPickupInfo.append(apartmentPU)
        businessOrderPickupInfo.append(numberPU)
        businessOrderPickupInfo.append(openTimePU)
        businessOrderPickupInfo.append(closeTimePU)
        businessOrderPickupInfo.append(consigneeNamePU)
        businessOrderPickupInfo.append(consigneePhonePU)
        
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
                                          isEditing: isEditingBO,
                                          style: .InputText,
                                          isRequire: _order.isRequireEdit(orderDV?.floor, .None))
        let apartmentDV = BusinessOrderForRow(title: "Apartment".localized,
                                              content: Slash(orderDV?.apartment),
                                              isEditing: isEditingBO,
                                              style: .InputText,
                                              isRequire: _order.isRequireEdit(orderDV?.apartment, .None))
        let numberDV = BusinessOrderForRow(title: "number".localized,
                                           content: Slash(orderDV?.number),
                                           isEditing: isEditingBO,
                                           style: .InputText,
                                           isRequire: _order.isRequireEdit(orderDV?.number, .None))
        let openTimeDV = BusinessOrderForRow(title: "open-time".localized,
                                             content: Slash(orderDV?.openTime),
                                             isEditing: isEditingBO,
                                             style: .Time,
                                             isRequire: _order.isRequireEdit(orderDV?.openTime, .None))
        let closeTimeDV = BusinessOrderForRow(title: "close-time".localized,
                                              content: Slash(orderDV?.closeTime),
                                              isEditing: isEditingBO,
                                              style: .Time,
                                              isRequire: _order.isRequireEdit(orderDV?.closeTime, .None))
        let consigneeNameDV = BusinessOrderForRow(title: "consignee-name".localized,
                                                  content: Slash(orderDV?.ctt_name),
                                                  isEditing: isEditingBO,
                                                  style: .InputText,
                                                  isRequire: _order.isRequireEdit(orderDV?.ctt_name, .None))
        let consigneePhoneDV = BusinessOrderForRow(title: "consignee-phone".localized,
                                                   content: Slash(orderDV?.ctt_phone),
                                                   isEditing: isEditingBO,
                                                   style: .InputText,
                                                   isRequire: _order.isRequireEdit(orderDV?.ctt_phone, .None))
        
        businessOrderDeliveryInfo.append(addressDV)
        businessOrderDeliveryInfo.append(floorDV)
        businessOrderDeliveryInfo.append(apartmentDV)
        businessOrderDeliveryInfo.append(numberDV)
        businessOrderDeliveryInfo.append(openTimeDV)
        businessOrderDeliveryInfo.append(closeTimeDV)
        businessOrderDeliveryInfo.append(consigneeNameDV)
        businessOrderDeliveryInfo.append(consigneePhoneDV)
        
        //Zone
        let isPickup = _order.typeID == OrderType.pickup.rawValue ? true : false
        self.addZone(isPickup: isPickup)
        
        //item
        tbvContent?.reloadData()
        guard let details = _order?.details else { return }
        if details.count != 0 {
            for (_,detail) in _order.details!.enumerated() {
                let skuItem = SKUModel().createSKUItem(skuContent: Slash(detail.name),
                                                       skuDataList: skuList,
                                                       uomDataList: uomList,
                                                       qtyContent: IntSlash(detail.pivot?.qty),
                                                       uomContent: Slash(detail.pivot?.uom?.name),
                                                       batchContent: Slash(detail.pivot?.batch_id))
                businessOrderItem.append(skuItem)
            }
        }
        tbvContent?.reloadData()
    }
    
    override func updateUI()  {
        super.updateUI()
        tbvContent?.allowsSelection = isEditingBO
        if isEditingBO {
            setupDataList()
        } else {
            setupDataDetailInfoforRows()
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
            guard let _order = order else { return }
            self.submitCreateBO(order: _order)
        @unknown default:
            return tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let isCanEdit = self.isEditingBO
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
        vc.dropDownStyle = style
        vc.itemDropDown = itemDropDown
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        App().window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
}

//MARK:
extension BusinessOrderDetailVC: BusinessOrderPickerTableViewCellDelegate {
    func didSelectedDopdown(_ cell: BusinessOrderPickerTableViewCell, _ btn: UIButton, style: DropDownType, indexPath: IndexPath, _ item: DropDownModel, _ titleContent: String) {
        self.currentIndexPath = indexPath
        let vc = DropDownViewController()
        vc.titleContent = titleContent
        vc.dropDownStyle = style
        vc.itemDropDown = item
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        App().window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
}

extension BusinessOrderDetailVC: DropDownViewControllerDelegate {
    func didSelectTime(item: String) {
        editItemInRow(item)
    }
    
    func didSelectItem(item: DropDownModel) {
        editItemInRow(nil, item)
    }
    
    func didDoneEditText(item: String) {
        editItemInRow(item)
    }
    
    func didSelectDate(date: Date) {
        let contentText = OnlyDateFormater.string(from: date)
        editItemInRow(contentText)
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
        getRentingOrderDetail()
    }
    
    private func getRentingOrderDetail(isFetch:Bool = false) {
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
    
    private func submitCreateBO(order:BusinessOrder) {
        self.showLoadingIndicator()
        SERVICES().API.createBusinessOrder(order: order) {[weak self] (result) in
            switch result {
            case .object(let _):
                self?.dismissLoadingIndicator()
                self?.showAlertView("uploaded-succesful".localized)
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
//                self?.dismissLoadingIndicator()
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
        checkOrderTypeRow()
        checkCustomerRow()
        checkOrderInfoFilled()
    }
    
    func renewAddressSKUData() {
        businessOrderPickupInfo.removeAll()
        businessOrderDeliveryInfo.removeAll()
        businessOrderItem.removeAll()
        order?.from = nil
        order?.to = nil
        order?.details = []
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
                        tempAddressPickUP.append(location)
                        break
                    } else {
                        tempAddressDelivery.append(location)
                        break
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
                        tempAddressDelivery.append(location)
                        break
                    } else {
                        tempAddressPickUP.append(location)
                        break
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
//        addressPickUpList = []
//        addressDeliveryList = []
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
        
        skuList = tempSKUList
        uomList = _uoms
    }
    
    func checkOrderInfoFilled() {
        isOrderInfoFilled = order?.typeID != nil && order?.customer != nil && (order?.dueDateFrom != nil || order?.dueDateFrom?.isEmpty == false) &&  (order?.dueDateTo?.isEmpty == false || order?.dueDateTo != nil)
        tbvContent?.reloadData()
    }
    
    func editItemInRow(_ result:String? = nil, _ item:DropDownModel? = nil) {
        guard let _indexPath = currentIndexPath else { return }
        let section = _indexPath.section
        let row = _indexPath.row
        let sectionInfo:BusinessOrderSection = BusinessOrderSection(rawValue: section)!
        switch sectionInfo {
        case .OrderInfo:
            editOrderInfo(row: row, result: result, item: item)
        case .Pickup:
            editOrderPickupInfo(row: row, result: result, item: item)
        case .Delivery:
            editOrderDeliveryInfo(row: row, result: result, item: item)
        case .SKUS:
            editOrderSKUInfo(row: row, index: (currentTag ?? 0), result: result, item: item)
        case .Submit:
            break
        }
        
        tbvContent?.reloadData()
    }
    
    func editOrderInfo(row:Int, result:String?, item:DropDownModel?) {
        var textContent = result
        let infoRow:BusinessOrderInfoRow = BusinessOrderInfoRow(rawValue: row)!
        switch infoRow {
        case .ORDER_TYPE:
            guard let _orderType = item?.result, let _order = order else { return }
            order?.typeID = _orderType == BusinessOrderType.Pickup.rawValue ? BusinessOrderType.Pickup.typeId : BusinessOrderType.Delivery.typeId
            order?.orderType = OrderType(rawValue: _order.typeID)!
            textContent = order!.orderType.name
            let isPickup = _orderType == BusinessOrderType.Pickup.rawValue ? true : false
            renewAddressSKUData()
            addZone(isPickup: isPickup)
        case .CUSTOMER:
            guard let _customer = item?.customers?.first else { return }
            order?.customer = _customer
            order?.customerId = String(_customer.id)
            order?.customerLocationId = String(_customer.id)
            textContent = order?.customer_name
            renewAddressSKUData()
        case .DUE_DATE_FROM:
            guard let _date = item?.date else { return }
            order?.dueDateFrom = DateFormatter.displayDateTimeUSWithSecond.string(from: _date)
            textContent = order?.dueDateFrom
        case .DUE_DATE_TO:
            guard let _date = item?.date else { return }
            order?.dueDateTo = DateFormatter.displayDateTimeUSWithSecond.string(from: _date)
            textContent = order?.dueDateTo
        case .REMARK:
            order?.remark = textContent
        }
        businessOrderInfo[row].content = Slash(textContent)
        setupViewAfterEdit()
        tbvContent?.reloadData()
    }
    func editOrderPickupInfo(row:Int,result:String?,item:DropDownModel?) {
        let infoRow:BusinessOrderAddressInfoRow = BusinessOrderAddressInfoRow(rawValue: row)!
        var textContent = result
        switch infoRow {
        case .ADDRESS:
            guard let _address = item?.locations?.first else { return }
            pickupItem.id = _address.id
            pickupItem.address = _address.address
            pickupItem.floor = _address.floor
            pickupItem.apartment = _address.apartment
            pickupItem.number = _address.number
            pickupItem.ctt_name = _address.ctt_name
            pickupItem.ctt_phone = _address.phone
            pickupItem.lattd = _address.lattd
            pickupItem.lngtd = _address.lngtd
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
        case .ZONE:
            guard let _zone = item?.zones?.first else { return }
            let zone:Zone = _zone
            order?.zone = zone
            textContent = zone.name
        }
        businessOrderPickupInfo[row].content = Slash(textContent)
        order?.from = pickupItem
        if order?.typeID == OrderType.pickup.rawValue {
            order?.customerLocationId = String(pickupItem.id)
        } else {
            order?.wareHouseId = String(pickupItem.id)
        }
        setupViewAfterEdit()
    }
    
    func editOrderDeliveryInfo(row:Int,result:String?,item:DropDownModel?) {
        let infoRow:BusinessOrderAddressInfoRow = BusinessOrderAddressInfoRow(rawValue: row)!
        var textContent = result
        switch infoRow {
        case .ADDRESS:
            guard let _address = item?.locations?.first else { return }
            deliveryItem.id = _address.id
            deliveryItem.address = _address.address
            deliveryItem.floor = _address.floor
            deliveryItem.apartment = _address.apartment
            deliveryItem.number = _address.number
            deliveryItem.ctt_name = _address.ctt_name
            deliveryItem.ctt_phone = _address.phone
            deliveryItem.lattd = _address.lattd
            deliveryItem.lngtd = _address.lngtd
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
        case .ZONE:
            guard let _zone = item?.zones?.first else { return }
            let zone:Zone = _zone
            order?.zone = zone
            textContent = zone.name
        }
        businessOrderDeliveryInfo[row].content = Slash(textContent)
        order?.to = deliveryItem
        order?.customerLocationId = String(deliveryItem.id)
        if order?.typeID == OrderType.delivery.rawValue {
            order?.customerLocationId = String(deliveryItem.id)
        } else {
            order?.wareHouseId = String(deliveryItem.id)
        }
        setupViewAfterEdit()
    }
    
    func editOrderSKUInfo(row: Int,index: Int, result:String?,item:DropDownModel?) {
        let index:BusinessOrderSKUInfoRow = BusinessOrderSKUInfoRow(rawValue: index)!
        var textContent = result
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
            textContent = _sku.skuName
        case .QUANTITY:
            skuItems[row].pivot?.qty = Int(textContent ?? "") ?? 0
        case .UOM:
            guard let _uom = item?.uoms?.first else { return }
            skuItems[row].pivot?.uom = _uom
            textContent = skuItems[row].pivot?.uom?.name ?? ""
        case .BATCH_ID:
            skuItems[row].pivot?.batch_id = textContent
        }
        businessOrderItem[row].itemContent[currentTag ?? 0]  = Slash(textContent)
        order?.details = skuItems
        skuItems[row].skuId = String(skuItems[row].id)
        skuItems[row].batchId = skuItems[row].pivot?.batch_id ?? ""
        skuItems[row].unitId = skuItems[row].pivot?.uom?.id ?? -1
        skuItems[row].qty = skuItems[row].pivot?.qty ?? -1
        setupViewAfterEdit()
    }
    
}


