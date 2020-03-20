//
//  BusinessOrderDetailVC.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/17/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

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
    
    private var customerItem = UserModel.UserInfo()
    private var pickupItem = Address()
    private var deliveryItem = Address()
    private var skuItems:[BusinessOrder.Detail] = []
    private var uomItem = BasicModel()
    
    var dateStringFilter = Date().toString()
    var order:BusinessOrder?
    var isEditingBO:Bool = false
    let orderTypeList:[String] = ["Pick-Up","Delivery"]
    var customerList:[String] = []
    let skuList:[String] = ["SKU001","SKU002","SKU003","SKU004","SKU005","SKU0010"]
    let addressList:[String] = ["72/24 Phan Dang Luu Phu Nhuan","268 To Hien Thanh Quan 10","289 Tran Van Dang","69/96 Le Hong Phong Quan 3","1569 Nguyen Huu Canh","129 duong nguyen van linh hem 10 phuong 15 quan 11 tp HCM"]
    let uomList:[String] = ["UOM1","UOM2","UOM3","UOM4","UOM5"]
    
    var customers:[CustomerModel]?
    
    var currentIndexPath:IndexPath?
    var currentTag:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
//        fetchData(showLoading: true)
        initVar()
        setupDataList()
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
    
    func setupDataDetailInforRows() {
        var _order:BusinessOrder!
        if order != nil {
            _order = order!
        }
        businessOrderInfo.removeAll()
        businessOrderPickupInfo.removeAll()
        businessOrderDeliveryInfo.removeAll()
        businessOrderItem.removeAll()
        
        
        let orderTypeString = _order.orderType.name
        let orderType = BusinessOrderForRow(title: "order-type".localized,
                                            content: Slash(orderTypeString),
                                            isEditing: isEditingBO,
                                            style: .Option,
                                            orderTypeList,
                                            isRequire: _order.isRequireEdit(orderTypeString, .OrderType))
        let customer = BusinessOrderForRow(title: "customer".localized,
                                           content: Slash(_order.customer_name),
                                           isEditing: isEditingBO,
                                           style: .Option,
                                           customerList,
                                           isRequire: _order.isRequireEdit(_order.customer_name, .Customer))
        let dueDate = BusinessOrderForRow(title: "due-date".localized,
                                          content: Slash(_order.dueDate),
                                          isEditing: isEditingBO,
                                          style: .Calendar,
                                          isRequire: _order.isRequireEdit(_order.dueDate, .DueDate))
        let remark = BusinessOrderForRow(title: "remark".localized,
                                          content: Slash(_order.remark),
                                          isEditing: isEditingBO,
                                          style: .InputText,
                                          isRequire: _order.isRequireEdit(_order.remark, .None))
        
        businessOrderInfo.append(orderType)
        businessOrderInfo.append(customer)
        businessOrderInfo.append(dueDate)
        businessOrderInfo.append(remark)
        
        // pick-up
        let orderPU = _order.from
        let addressPU = BusinessOrderForRow(title: "Address".localized,
                                            content: Slash(orderPU?.address),
                                            isEditing: isEditingBO,
                                            style: .InputText,
                                            addressList,
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
        let addressDV = BusinessOrderForRow(title: "Address".localized,
                                            content: Slash(orderDV?.address),
                                            isEditing: isEditingBO,
                                            style: .InputText,
                                            addressList,
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
            setupDataDetailInforRows()
        } else {
            setupDataDetailInforRows()
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
    
    func setupDataList() {
        self.getCustomerList()
    }
    
    func setupCustomerList() {
        guard let _customers = customers else { return }
        for (_,customer) in _customers.enumerated() {
            customerList.append(customer.name)
        }
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
        let numberOfSection = isEditingBO ? arrTitleHeader.count : (arrTitleHeader.count - 1)
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
            print(order)
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
    func didSelectedDopdown(_ cell: BusinessOrderItemTableViewCell, _ btn: UIButton, style: DropDownType, _ data: [String]?, _ titleContent: String, tag: Int, indexPath: IndexPath) {
        self.currentIndexPath = indexPath
        self.currentTag = tag
        let vc = DropDownViewController()
        vc.titleContent = titleContent
        vc.dropDownStyle = style
        vc.itemsOrigin = data
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
}

//MARK:
extension BusinessOrderDetailVC: BusinessOrderPickerTableViewCellDelegate {
    func didSelectedDopdown(_ cell: BusinessOrderPickerTableViewCell, _ btn: UIButton, style: DropDownType, indexPath: IndexPath, _ data: [String], _ titleContent: String) {
        self.currentIndexPath = indexPath
        let vc = DropDownViewController()
        vc.titleContent = titleContent
        vc.dropDownStyle = style
        vc.itemsOrigin = data
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
}

extension BusinessOrderDetailVC: DropDownViewControllerDelegate {
    func didDoneEditText(item: String) {
        editItemInRow(item: item)
    }
    
    func didSelectTime(item: String) {
        editItemInRow(item: item)
    }
    
    func didSelectDate(date: Date) {
        let contentText = OnlyDateFormater.string(from: date)
        editItemInRow(item: contentText)
    }
    
    func didSelectItem(item: String) {
        editItemInRow(item: item)
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
    
    private func getCustomerList() {
        guard let _orderID = order?.id else { return }
        SERVICES().API.getCustomerList(orderId: _orderID) {[weak self] (result) in
            switch result {
            case .object(let data):
                self?.customers = data.data
                self?.setupCustomerList()
            case .error(let error):
                self?.dismissLoadingIndicator()
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
}

// MARK: - EDIT BUSINESS ORDER
extension BusinessOrderDetailVC {
    func editItemInRow(item:String) {
        guard let _indexPath = currentIndexPath else { return }
        let section = _indexPath.section
        let row = _indexPath.row
        let sectionInfo:BusinessOrderSection = BusinessOrderSection(rawValue: section)!
        switch sectionInfo {
        case .OrderInfo:
            businessOrderInfo[row].content = item
            editOrderInfo(row: row, item: item)
        case .Pickup:
            businessOrderPickupInfo[row].content = item
            editOrderPickupInfo(row: row, item: item)
        case .Delivery:
            businessOrderDeliveryInfo[row].content = item
            editOrderDeliveryInfo(row: row, item: item)
        case .SKUS:
            businessOrderItem[row].itemContent[currentTag ?? 0]  = item
            editOrderSKUInfo(row: row, index: (currentTag ?? 0), item: item)
        case .Submit:
            break
        }
        tbvContent?.reloadData()
    }
    
    func editOrderInfo(row:Int,item:String) {
        let row:BusinessOrderInfoRow = BusinessOrderInfoRow(rawValue: row)!
        switch row {
        case .ORDER_TYPE:
            order?.typeID = item == BusinessOrderType.Pickup.rawValue ? BusinessOrderType.Pickup.typeId : BusinessOrderType.Delivery.typeId
        case .CUSTOMER:
            order?.customer = customerItem
        case .DUE_DATE:
            order?.dueDate = item
        case .REMARK:
            order?.remark = item
            
        }
    }
    func editOrderPickupInfo(row:Int,item:String) {
        let row:BusinessOrderAddressInfoRow = BusinessOrderAddressInfoRow(rawValue: row)!
        switch row {
        case .ADDRESS:
            pickupItem.address = item
        case .FLOOR:
            pickupItem.floor = item
        case .APARTMENT:
            pickupItem.apartment = item
        case .NUMBER:
            pickupItem.number = item
        case .OPEN_TIME:
            pickupItem.openTime = item
        case .CLOSE_TIME:
            pickupItem.closeTime = item
        case .CONSIGNEE_NAME:
            pickupItem.ctt_name = item
        case .CONSIGNEE_PHONE:
            pickupItem.ctt_phone = item
        }
        order?.from = pickupItem
    }
    
    func editOrderDeliveryInfo(row:Int,item:String) {
        let row:BusinessOrderAddressInfoRow = BusinessOrderAddressInfoRow(rawValue: row)!
        switch row {
        case .ADDRESS:
            deliveryItem.address = item
        case .FLOOR:
            deliveryItem.floor = item
        case .APARTMENT:
            deliveryItem.apartment = item
        case .NUMBER:
            deliveryItem.number = item
        case .OPEN_TIME:
            deliveryItem.openTime = item
        case .CLOSE_TIME:
            deliveryItem.closeTime = item
        case .CONSIGNEE_NAME:
            deliveryItem.ctt_name = item
        case .CONSIGNEE_PHONE:
            deliveryItem.ctt_phone = item
        }
        order?.to = deliveryItem
    }
    
    func editOrderSKUInfo(row: Int,index: Int, item:String) {
        let index:BusinessOrderSKUInfoRow = BusinessOrderSKUInfoRow(rawValue: index)!
        switch index {
        case .SKU:
            skuItems[row].name = item
        case .QUANTITY:
            let json:[String:Any] = ["qty":Int(item) ?? 0]
            let pivot = BusinessOrder.Detail.Pivot(JSON: json)
            skuItems[row].pivot = pivot
        case .UOM:
            let json:[String:Any] = ["uom":uomItem.toJSON()]
            let pivot = BusinessOrder.Detail.Pivot(JSON: json)
            skuItems[row].pivot = pivot
        case .BATCH_ID:
            let json:[String:Any] = ["batch_id":item]
            let pivot = BusinessOrder.Detail.Pivot(JSON: json)
            skuItems[row].pivot = pivot
        }
        order?.details = skuItems
    }
    
}


