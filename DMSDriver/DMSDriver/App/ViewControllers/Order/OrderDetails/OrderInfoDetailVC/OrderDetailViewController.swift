//
//  OrderDetailViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreLocation
import Photos


enum OrderDetailSection:Int {
    case sectionMap = 0
    case sectionOrderInfo
    case sectionFrom
    case sectionTo
    case sectionCOD
    case sectionNatureOfGoods
    case sectionSignature
    case sectionPictures
//    case sectionAddNote
    case sectionDescription
    
    static let count: Int = {
        var max: Int = 0
        while let _ = OrderDetailSection(rawValue: max) { max += 1 }
        return max
    }()
    
    var indexSet:IndexSet {
        return IndexSet(integer: self.rawValue)
    }
}

typealias UpdateOrderDetailCallback = (Bool,Order) -> Void

class OrderDetailViewController: BaseOrderDetailViewController {
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var updateStatusButton: UIButton?
    @IBOutlet weak var shortcutUpdateStatusButton: UIButton?
    @IBOutlet weak var btnUnable: UIButton?
    @IBOutlet weak var vAction: UIView?
    @IBOutlet weak var lblOrderId: UILabel?
    @IBOutlet weak var lblDateTime: UILabel?
    @IBOutlet weak var unableToStartButton: UIButton!
    @IBOutlet weak var navigateButton: UIButton!
    @IBOutlet weak var addNoteButton: UIButton!
    
    fileprivate var orderInforDetail = [OrderDetailInforRow]()
    fileprivate var orderInforFrom = [OrderDetailInforRow]()
    fileprivate var orderInforTo = [OrderDetailInforRow]()
    fileprivate var orderCODInfo = [OrderDetailInforRow]()
    fileprivate var orderInforNatureOfGoods = [OrderDetailInforRow]()
    fileprivate let cellIdentifier = "OrderDetailTableViewCell"
    fileprivate let cellSKUInfoIdentifier = "OrderDetailSKUCell"
    fileprivate let headerCellIdentifier = "OrderDetailHeaderCell"
    fileprivate let addressCellIdentifier =  "OrderDetailAddressCell"
    fileprivate let orderDropdownCellIdentifier = "OrderDetailDropdownCell"
    fileprivate let orderDetailMapCellIdentifier = "OrderDetailMapCell"
    fileprivate let orderPictureTableViewCell = "PictureTableViewCell"
    fileprivate let orderDetailNatureOfGoodsCell = "OrderDetailNatureOfGoodsCell"

    fileprivate var arrTitleHeader:[String] = []
    fileprivate let heightHeader:CGFloat = 65
    fileprivate var isMapHidden:Bool = true
    fileprivate var isReasonListShowing:Bool = false
    fileprivate var tempActualQty = [Int:Int]()
    
    var dateStringFilter = Date().toString()
    var btnGo: UIButton?
    var isHaveMoreLegs:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        fetchData(showLoading: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isReasonListShowing {
            isReasonListShowing = false
            return
        }
        updateUI()
    }
    
    override func reachabilityChangedNetwork(_ isAvailaibleNetwork: Bool) {
        super.reachabilityChangedNetwork(isAvailaibleNetwork)
        //checkConnetionInternet?(notification, isAvailaibleNetwork)
    }
    
    override func updateUI()  {
        super.updateUI()
        self.updateButtonStatus()
    }
    
    
    override func updateNavigationBar() {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Back_Menu, "")
    }
    
    override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Detail".localized)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        tableView?.reloadSections(OrderDetailSection.sectionNatureOfGoods.indexSet, with: .automatic)
//    }
    
    fileprivate func cancelOrder(reason:Reason,isUnableToFinish:Bool) {
        let statusNeedToUpdate = (isUnableToFinish) ? StatusOrder.UnableToFinish.rawValue : StatusOrder.CancelStatus.rawValue
        updateOrderStatus(statusNeedToUpdate, cancelReason: reason)
    }
    
    //MARK: - Initialize
    private func setupTableView() {
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableView.automaticDimension
    }
    
    private func initVar()  {
        arrTitleHeader = ["",
                          "order-info".localized.uppercased(),
                          "pickup".localized.uppercased(),
                          "Delivery".localized.uppercased(),
                          "COD".localized.uppercased(),
                          "SKUs".localized.uppercased(),
                          "Signature".localized.uppercased(),
                          "Picture".localized.uppercased(),
//                          "add-note".localized.uppercased()
        ]
        setupDataDetailInforRows()
    }
    
    private func initUI()  {
        self.setupTableView()
        lblOrderId?.text = "order".localized + " #\(orderDetail?.id ?? 0)"
        
        var timeStart = "NA".localized
        var timeEnd = "NA".localized
        var date = "NA".localized
        if let start = orderDetail?.from?.start_time?.date {
            timeStart = DateFormatter.hour24Formater.string(from: start)
        }
        
        if let end = orderDetail?.to?.end_time?.date {
            timeEnd = DateFormatter.hour24Formater.string(from: end)
            date = DateFormatter.shortDate.string(from: end)
        }
        
        lblDateTime?.text = "\(timeStart) - \(timeEnd) \(date)"
        //setup NavigateButton
        navigateButton.backgroundColor = AppColor.mainColor
//        shortcutUpdateStatusButton = updateStatusButton
    }
    
    func layoutAddNoteButton() {
        addNoteButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        addNoteButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        addNoteButton.layer.shadowOpacity = 1.0
        addNoteButton.layer.shadowRadius = 10
        addNoteButton.layer.masksToBounds = false
    }
    
    private func setupDataDetailInforRows() {
        orderInforDetail.removeAll()
        orderInforFrom.removeAll()
        orderInforTo.removeAll()
        orderInforNatureOfGoods.removeAll()
        orderCODInfo.removeAll()
        
        guard let order = orderDetail else { return }
        
        var startFromDate = ""
        if let start = order.from?.start_time?.date {
            startFromDate = Slash(ShortNormalDateFormater.string(from: start))
        }
        var endFromDate = ""
        if let end = order.from?.end_time?.date {
            endFromDate = Slash(ShortNormalDateFormater.string(from: end))
        }
        var startToDate = ""
        if let start = order.to?.start_time?.date {
            startToDate = Slash(ShortNormalDateFormater.string(from: start))
        }
        var endToDate = ""
        if let end = order.to?.end_time?.date {
            endToDate = Slash(ShortNormalDateFormater.string(from: end))
        }
        
        let customerItem = OrderDetailInforRow("customer-name".localized,
                                             Slash(order.customer?.userName))
        let consigneeName = OrderDetailInforRow("consignee-name".localized,
                                               Slash(order.consigneeName))
        let remark = OrderDetailInforRow("remark".localized,
                                              Slash(order.remark))
        let remarkForDriver = OrderDetailInforRow("remark-for-driver".localized,
                                                  Slash(order.remarkDriver))
        let remarkForLocation = OrderDetailInforRow("remark-for-location".localized,
                                                    Slash(order.remarkLocation))
        let orderId = OrderDetailInforRow("order-id".localized,"#\(order.id)")
        
        //NEW
        let orderType = OrderDetailInforRow("order-type".localized,order.orderType.name)
        let division = OrderDetailInforRow("division".localized,Slash(order.division?.name))
        let zone = OrderDetailInforRow("zone".localized,Slash(order.zone?.name))
        let purchaseOrderID = OrderDetailInforRow("purchase-order-id".localized,IntSlash(order.purchaseOrderID),true)
        

        orderInforDetail.append(orderId)
        orderInforDetail.append(orderType)
        orderInforDetail.append(purchaseOrderID)
        orderInforDetail.append(customerItem)
        orderInforDetail.append(consigneeName)
        orderInforDetail.append(division)
        orderInforDetail.append(zone)
        orderInforDetail.append(remark)
        orderInforDetail.append(remarkForDriver)
        orderInforDetail.append(remarkForLocation)
        //orderInforStatus.append(urgency)
        
//        if  (order.statusOrder == .CancelStatus ||
//             order.statusOrder == .UnableToFinish),
//            let _orderDetail = orderDetail{
//            let reason = OrderDetailInforRow("failure-cause".localized,_orderDetail.reason?.name ?? "-")
//            let mess = OrderDetailInforRow("Message".localized,_orderDetail.reason_msg ?? "-")
//            orderInforDetail.append(reason)
//            orderInforDetail.append(mess)
//        }
        
        let fromLocationName = OrderDetailInforRow("location-name".localized, Slash(order.from?.loc_name),false)
        let fromAddress = OrderDetailInforRow("Address".localized, E(order.from?.address),true)
        let fromContactName = OrderDetailInforRow("contact-name".localized,order.from?.ctt_name ?? "-")
        let fromContactPhone = OrderDetailInforRow("contact-phone".localized,order.from?.ctt_phone ?? "-",true)
        let fromStartTime = OrderDetailInforRow("start-time".localized,startFromDate,false)
        let fromEndtime = OrderDetailInforRow("end-time".localized,endFromDate,false)
        let fromServiceTime = OrderDetailInforRow("service-time".localized,Slash(order.from?.serviceTime),false)
        let fromFloor = Slash(order.from?.floor)
        let fromApartment = Slash(order.from?.apartment)
        let fromNumber = Slash(order.from?.number)
        
        let fromAddressDetail = "\(fromFloor)/\(fromApartment)/\(fromNumber)"
        let fromAddressDetailRecord = OrderDetailInforRow("floor-apt-number".localized,fromAddressDetail,false)

        let toAddress = OrderDetailInforRow("Address".localized, E(order.to?.address),true)
        let toContactName = OrderDetailInforRow("contact-name".localized,order.to?.ctt_name ?? "-")
        let toContactPhone = OrderDetailInforRow("contact-phone".localized,order.to?.ctt_phone ?? "-", true)
        let toStartTime = OrderDetailInforRow("start-time".localized,startToDate,false)
        let tomEndtime = OrderDetailInforRow("end-time".localized,endToDate,false)
        let toLocationName = OrderDetailInforRow("location-name".localized, Slash(order.to?.loc_name),false)
        let toServiceTime = OrderDetailInforRow("service-time".localized,Slash(order.to?.serviceTime),false)
        
        let toFloor = Slash(order.to?.floor)
        let toApartment = Slash(order.to?.apartment)
        let toNumber = Slash(order.to?.number)
        
        let toAddressDetail = "\(toFloor)/\(toApartment)/\(toNumber)"
        let toAddressDetailRecord = OrderDetailInforRow("floor-apt-number".localized,toAddressDetail,false)
        
        let codAmount = OrderDetailInforRow("cod-amount".localized,"\(order.codAmount ?? 0)",false)
        let codRemark = OrderDetailInforRow("cod-remark".localized,Slash(order.codComment),false)
        
        orderCODInfo.append(codAmount)
        orderCODInfo.append(codRemark)

        orderInforFrom.append(fromLocationName)
        orderInforFrom.append(fromAddress)
        orderInforFrom.append(fromAddressDetailRecord)
        orderInforFrom.append(fromContactName)
        orderInforFrom.append(fromContactPhone)
        orderInforFrom.append(fromStartTime)
        orderInforFrom.append(fromEndtime)
        orderInforFrom.append(fromServiceTime)

        orderInforTo.append(toLocationName)
        orderInforTo.append(toAddress)
        orderInforTo.append(toAddressDetailRecord)
        orderInforTo.append(toContactName)
        orderInforTo.append(toContactPhone)
        orderInforTo.append(toStartTime)
        orderInforTo.append(tomEndtime)
        orderInforTo.append(toServiceTime)

        tableView?.reloadData()
    }
    
    func showReasonView(isUnableToFinish:Bool) {
        isReasonListShowing = true
        ReasonSkipView.present(inViewController: self) {[weak self] (success, reason) in
            guard let _reason = reason else {return}
            self?.cancelOrder(reason: _reason, isUnableToFinish: isUnableToFinish)
        }
    }
    
    func showReturnReasonView(completionHandler:@escaping (_ reason:Reason)->Void) {
        ReasonSkipView.present(inViewController: self, isCancelledReason: false) {(success, reason) in
            guard let _reason = reason else {return}
            completionHandler(_reason)
        }
    }
    
//    func showPalletReturnedPopUp() {
//        let alert = UIAlertController(title: "returned-pallets".localized, message: "number-of-returned-pallets".localized, preferredStyle: .alert)
//        // 2. Grab the value from the text field, and print it when the user clicks Submit.
//        let submitButton = UIAlertAction(title: "submit".localized, style: .default, handler: { [weak alert] (_) in
//            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
//            let returnedPalletQty = Int(textField?.text ?? "0")!
//            if let detail = self.orderDetail?.details?.first {
//                detail.returnedPalletQty = returnedPalletQty
//            }
//            self.handleReturnedPalletAction()
//            })
//
//        submitButton.isEnabled = false
//
//        //3. Add the text field. You can configure it however you need.
//        alert.addTextField(configurationHandler: { (textField) in
//            textField.keyboardType = .numberPad
//            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
//                submitButton.isEnabled = textField.text!.length > 0
//            }
//        })
//
//        alert.addAction(submitButton)
//        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: {
//            action in
//        }))
//
//        // 4. Present the alert.
//        self.present(alert, animated: true, completion: nil)
//    }
    
    func showCODPopUp() {
        guard let codAmount = orderDetail?.codAmount else { return }
        let title = "cod-received".localized
        let message = String(format: "did-you-receive-cod-amount".localized, "\(codAmount)")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.keyboardType = .decimalPad
            textField.text = "\(codAmount)"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "submit".localized, style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            guard let text = textField?.text, let value = Double(text), value <= codAmount && value > 0.0  else {
                let msg = String(format: "cod-must-be-less-than-or-equal".localized, "\(codAmount)")
                self.showAlertView(msg)
                return
            }
            self.submitCODValue(value)
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: {
            action in
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func submitCODValue(_ value:Double) {
        self.showLoadingIndicator()
        SERVICES().API.updateCODValue(value,orderID: orderDetail!.id) { [weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result {
            case .object(_):
                self?.orderDetail?.cod_rcvd = "\(value)"
                self?.handleFinishAction()
            case .error(let error):
                self?.showAlertView(error.getMessage(), completionHandler: { (action) in
                    self?.fetchData(showLoading: true)
                })
            }
        }
    }
    
    func updateLoadedQuantity(order:Order) {
        let status = order.getLoadedStatusWithLoadingQuantity()
        updateOrderStatus(status.rawValue, updateDetailType: .Load)
    }
    
    
    func handleLoadAction() {
        guard let order = orderDetail else { return }
        if order.isValidAllLoadedQty {
            updateLoadedQuantity(order: order)
        } else {
            let pickUpMsg = "picked-up-quantity-must-be-less-than-or-equal-the-quantity".localized
            let loadingMsg = "loaded-quantity-must-be-less-than-or-equal-the-quantity".localized
            let message = order.isPickUpType ? pickUpMsg : loadingMsg
            showAlertView(message)
            return
        }
    }
    
    func handleRequestMoreOrdersAction() {
        let alert = UIAlertController(title: "Please enter amount of legs you would like to request", message: "", preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Submit", style: .default, handler: { (action) -> Void in
            // Get TextFields text
            let numberOfRequestTxt = alert.textFields![0]
            let amount = Int(numberOfRequestTxt.text ?? "0") ?? 0
            //callAPI
//            submitAction.isEnabled = amount > 0 ? true : false
            self.uploadRequestMoreOrderWith(amount)
        })
        submitAction.isEnabled = false
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        // textField for amount of order
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Amount of legs"
            textField.keyboardType = .asciiCapableNumberPad
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
                {_ in
                    let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let amountOflegs = Int(textField.text ?? "0") ?? 0
                    let textIsNotEmpty = (textCount > 0 && amountOflegs > 0)
                    submitAction.isEnabled = textIsNotEmpty
            })
        }
        
        // Add actions
        alert.addAction(cancel)
        alert.addAction(submitAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func handleUpdatingStatus() {
        guard let order = orderDetail else { return }
        switch order.statusOrder.rawValue {
        case StatusOrder.newStatus.rawValue:
            handleLoadAction()
            break
        case StatusOrder.Loaded.rawValue, StatusOrder.PartialLoaded.rawValue:
            let title = order.isPickUpType ? "back-to-warehouse".localized : "do-you-want-to-start-this-order".localized
            App().showAlertView(title,
                                positiveTitle: "YES".localized,
                                positiveAction: {[weak self] (ok) in
                                    let statusNeedUpdate = StatusOrder.InTransit.rawValue
                                    self?.updateOrderStatus(statusNeedUpdate)
                                    
            }, negativeTitle: "NO".localized) { (cancel) in
                //
            }
        case StatusOrder.InTransit.rawValue:
                handleFinishAction()
            break
        case StatusOrder.deliveryStatus.rawValue, StatusOrder.PartialDelivered.rawValue:
            handleRequestMoreOrdersAction()
            break
        default:
            break
        }
    }
    
    func redirectToPurchaseOrderDetail() {
        let vc:PurchaseOrderDetailVC = PurchaseOrderDetailVC.loadSB(SB: .PurchaseOrder)
        vc.order = PurchaseOrder()
        vc.order?.id = orderDetail?.purchaseOrderID ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - ACTION
    @IBAction func tapUpdateStatusButtonAction(_ sender: UIButton) {
        handleUpdatingStatus()
    }
    
    
    @IBAction func onUnableToStartTouchUp(_ sender: UIButton) {
        guard let _order = orderDetail else { return }
        let isCancelled = _order.isNewStatus
        self.showReasonView(isUnableToFinish: !isCancelled)
    }
    
    @IBAction func tapOrderNavigateButton(_ sender: Any) {
        navigateButton.isSelected = !navigateButton.isSelected
        isMapHidden = !navigateButton.isSelected
        tableView?.reloadSections(OrderDetailSection.sectionMap.indexSet, with: .top)
//        tableView?.reloadData()
    }
    
    @IBAction func onNoteManagementTouchUp(_ sender: UIButton) {
        guard let _order = orderDetail else { return }
        let vc:NoteManagementViewController = .loadSB(SB: .Common)
        vc.order = _order
        vc.notes = _order.notes
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


// MARK: - UITableView
extension OrderDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrTitleHeader.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _orderDetail = self.orderDetail, let orderSection:OrderDetailSection = OrderDetailSection(rawValue: section) else {
            return 0
        }
        switch orderSection {
        case .sectionMap:
            return isMapHidden ? 0 : 1
        case .sectionOrderInfo:
            return orderInforDetail.count
        case .sectionFrom:
            return orderInforFrom.count
        case .sectionTo:
            return orderInforTo.count
        case .sectionCOD:
//            return (_orderDetail.isHasCOD) ? orderCODInfo.count : 0
            return 0
        case .sectionNatureOfGoods:
            return orderDetail?.details?.count ?? 0
        case .sectionSignature:
            return orderDetail?.signature != nil ? 1 : 0
        case .sectionPictures:
            return orderDetail?.pictures?.count ?? 0
//        case .sectionAddNote:
//            return 0;
        case .sectionDescription:
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let _orderDetail = self.orderDetail, let orderSection:OrderDetailSection = OrderDetailSection(rawValue: section) else {
            return 0
        }
        switch orderSection {
        case .sectionMap:
            return 0
        case .sectionCOD:
//            return (_orderDetail.isHasCOD) ? heightHeader : CGFloat.leastNormalMagnitude
            return CGFloat.leastNormalMagnitude
//        case .sectionSignature, .sectionPictures:
//            return (_orderDetail.isLoaded || _orderDetail.isNewStatus) ? CGFloat.leastNormalMagnitude : heightHeader
        default:
            return heightHeader
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let _orderDetail = self.orderDetail, let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as? OrderDetailTableViewCell{
            headerCell.nameLabel?.text = arrTitleHeader[section];
            headerCell.btnEdit?.tag = section
            headerCell.delegate = self
            headerCell.btnEdit?.isHidden = true
            headerCell.btnStatus?.isHidden = true
            
            let statusesShouldAllowToSignAndUpload = (_orderDetail.isInTransit || _orderDetail.isFinished)
            let statusesNotAllowToSignAnUpload = (_orderDetail.isPartialDelivered || _orderDetail.isDelivery)
            let orderSection:OrderDetailSection = OrderDetailSection(rawValue: section)!
            switch orderSection {
            case .sectionOrderInfo:
                headerCell.btnStatus?.isHidden = false
                headerCell.btnStatus?.borderWidth = 1.0
                let status = StatusOrder(rawValue: E(orderDetail?.status?.code)) ?? StatusOrder.newStatus
                headerCell.btnStatus?.setTitle(status.statusName.localized, for: .normal)
                headerCell.btnStatus?.borderColor = orderDetail?.colorStatus
                headerCell.btnStatus?.setTitleColor(orderDetail?.colorStatus, for: .normal)
                
            case .sectionSignature:
                let hasSigned = orderDetail?.signature != nil
                var isHidden = hasSigned || !statusesShouldAllowToSignAndUpload
                isHidden = statusesNotAllowToSignAnUpload ? true : isHidden
                headerCell.btnEdit?.isHidden = isHidden
            case .sectionPictures:
                headerCell.btnEdit?.isHidden = !statusesShouldAllowToSignAndUpload
//            case .sectionAddNote:
//                headerCell.btnEdit?.isHidden = false
                
                case .sectionCOD:
//                    if !_orderDetail.isHasCOD {
//                        return nil
//                    }
                    return nil
            default:
                break
            }
            
            let headerView = UIView()
            headerView.addSubview(headerCell)
            headerCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: heightHeader)
            return headerView;
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let _orderDetail = self.orderDetail, let orderSection:OrderDetailSection = OrderDetailSection(rawValue: section) else { return 10 }
        
        if orderSection == OrderDetailSection.sectionMap && isMapHidden {
            return CGFloat.leastNormalMagnitude
        }
        
//        if orderSection == OrderDetailSection.sectionCOD && !_orderDetail.isHasCOD {
//            return CGFloat.leastNormalMagnitude
//        }
        if orderSection == OrderDetailSection.sectionCOD {
            return CGFloat.leastNormalMagnitude
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view:UIView = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let orderSection:OrderDetailSection = OrderDetailSection(rawValue: indexPath.section)!
        switch orderSection {
        case .sectionMap:
            return cellMap(tableView,indexPath)
        case .sectionOrderInfo:
            return cellInfoDetail(tableView,indexPath)
        case .sectionFrom:
            return cellInfoFromSection(tableView,indexPath)
        case .sectionTo:
            return cellInfoToSection(tableView,indexPath)
        case .sectionCOD:
            return cellCODInfo(tableView,indexPath)
        case .sectionNatureOfGoods:
            //return cellNatureOfGood(tableView,indexPath)
            return cellSKUsInfoSection(tableView, indexPath)
        case .sectionSignature:
            return cellSignature(tableView, indexPath)
        case .sectionPictures:
            return cellPicture(tableView,indexPath)
        case .sectionDescription:
           return cellDiscription(tableView,indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let orderSection = OrderDetailSection(rawValue:indexPath.section) else {
            return
        }
        let row = indexPath.row
        switch orderSection {
        case .sectionOrderInfo:
            let purchaseOrderIDRow = 2
            if row == purchaseOrderIDRow {
                redirectToPurchaseOrderDetail()
            }
        case .sectionMap:
            guard let _orderDetail = orderDetail else { return }
            let lat = _orderDetail.to?.lattd?.doubleValue ?? 0.0
            let lng = _orderDetail.to?.lngtd?.doubleValue ?? 0.0
            if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                UIApplication.shared.openURL(NSURL(string:
                    "comgooglemaps://?saddr=My%20Location&daddr=\(lat),\(lng)")! as URL)
            } else {
                UIApplication.shared.openURL(NSURL(string:
                    "https://maps.google.com/?saddr=My%20Location&daddr=\(lat),\(lng)")! as URL)
            }
            break
        case .sectionFrom:
            if row != 0 &&  // from-address, contact-phone
                row != orderInforFrom.count - 3 {
                return
            }
            
            if row == 0{ //from-address
//                let vc:OrderDetailMapViewController = .loadSB(SB: .Order)
//                vc.orderDetail = orderDetail
//                if let _orderDetail = orderDetail,
//                    let lng = _orderDetail.from?.lngtd,
//                    let lat = _orderDetail.from?.lattd  {
//                    let location = CLLocationCoordinate2D(latitude: lat.doubleValue ,
//                                                          longitude: lng.doubleValue)
//                    vc.orderLocation = location
//                }
//
//                self.navigationController?.pushViewController( vc, animated: true)
            }else {
                let item = orderInforFrom[row]
                callPhone(phone: item.content)
            }
            
        case .sectionTo:
            if row != 0 &&  // to-address, contact-phone
                row != orderInforTo.count - 3 {
                return
            }
            
            if row == 0{
//                let vc:OrderDetailMapViewController = .loadSB(SB: .Order)
//                vc.orderDetail = orderDetail
//
//                if let _orderDetail = orderDetail,
//                    let lng = _orderDetail.to?.lngtd,
//                    let lat = _orderDetail.to?.lattd  {
//                    let location = CLLocationCoordinate2D(latitude: lat.doubleValue ,
//                                                          longitude: lng.doubleValue)
//                    vc.orderLocation = location
//                }
//                self.navigationController?.pushViewController( vc, animated: true)
                
            }else {
                let item = orderInforTo[row]
                callPhone(phone: item.content)
            }
            
        case .sectionSignature:
            if ReachabilityManager.isNetworkAvailable {
                self.showImage(nil, linkUrl: orderDetail?.signature?.url, placeHolder: nil)
            } else {
                self.showImage(UIImage(data: orderDetail?.signature?.contentFile ?? Data()), linkUrl: nil, placeHolder: nil)
            }
        case .sectionPictures:
            let picture = orderDetail?.pictures?[row]
            if ReachabilityManager.isNetworkAvailable {
                self.showImage(nil, linkUrl: picture?.url, placeHolder: nil)
            } else {
                self.showImage(UIImage(data: orderDetail?.pictures?[row].contentFile ?? Data()), linkUrl: nil, placeHolder: nil)
            }
        default:
            break
        }
    }
}

//MARK: - CELL FUNTION
fileprivate extension OrderDetailViewController {
    func cellMap(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: orderDetailMapCellIdentifier, for: indexPath) as! OrderDetailTableViewCell
        cell.delegate = self
        cell.btnGo?.isHidden = (orderDetail?.statusOrder != StatusOrder.newStatus &&
                                orderDetail?.statusOrder != StatusOrder.InTransit)
        btnGo = cell.btnGo
        cell.nameLabel?.text = orderDetail?.to?.address
        cell.drawRouteMap(order: orderDetail)
        return cell
    }
    
    func cellInfoFromSection(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let item = orderInforFrom[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                    for: indexPath) as! OrderDetailTableViewCell
        cell.orderDetailItem = item
        cell.delegate = self
        cell.selectionStyle = .none
        cell.vContent?.cornerRadius = 0
        if indexPath.row == orderInforFrom.count - 1{
            cell.vContent?.roundCornersLRB()
        }
        return cell
    }
    
    func cellInfoToSection(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let item = orderInforTo[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OrderDetailTableViewCell
        cell.orderDetailItem = item
        cell.selectionStyle = .none
        cell.vContent?.cornerRadius = 0
        if indexPath.row == orderInforTo.count - 1{
            cell.vContent?.roundCornersLRB()
        }
        return cell
  
    }
    
    func cellSKUsInfoSection(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellSKUInfoIdentifier, for: indexPath) as! OrderDetailSKUCell
        cell.selectionStyle = .none
        guard let order = orderDetail, let detail = order.details?[indexPath.row] else { return cell }
        cell.delegate = self
        let isNotUpdate = detail.pivot?.deliveredQty == 0
        cell.tempActualQty = isNotUpdate ? nil : tempActualQty[detail.pivot?.id ?? 0]
        cell.configureCell(detail: detail, order: order)
        cell.vContent?.cornerRadius = 0
        if indexPath.row == order.details!.count - 1{
            cell.vContent?.roundCornersLRB()
        }
        
        
        return cell
        
    }
    
    func cellInfoDetail(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let item = orderInforDetail[indexPath.row]
  
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OrderDetailTableViewCell
        cell.orderDetailItem = item
        cell.selectionStyle = .none
        cell.vContent?.noRoundCornersLRT()
        if indexPath.row == orderInforDetail.count - 1 {
            cell.vContent?.roundCornersLRB()
        }
        return cell
    }
    
    func cellCODInfo(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let item = orderCODInfo[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OrderDetailTableViewCell
        cell.orderDetailItem = item
        cell.selectionStyle = .none
        cell.vContent?.noRoundCornersLRT()
        if indexPath.row == orderInforDetail.count - 1 {
            cell.vContent?.roundCornersLRB()
        }
        return cell
    }
    
    func cellSignature(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: orderPictureTableViewCell,
                                                 for: indexPath) as! PictureTableViewCell
        cell.selectionStyle = .none
        if let sig =  orderDetail?.signature {
            cell.nameLabel.text = sig.name
            if ReachabilityManager.isNetworkAvailable {
                if sig.url_thumbnail != nil {
                    cell.imgView.sd_setImage(with: URL(string: E(sig.url_thumbnail)),
                                             placeholderImage: #imageLiteral(resourceName: "place_holder"),
                                             options: .refreshCached, completed: nil)
                }else {
                    cell.imgView.image = UIImage(data: sig.contentFile ?? Data())
                }
            } else {
                cell.imgView.image = UIImage(data: sig.contentFile ?? Data())
            }
        }
        cell.selectionStyle = .none
        cell.vContent?.roundCornersLRB()
        return cell
    }
    
    func cellPicture(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: orderPictureTableViewCell, for: indexPath) as! PictureTableViewCell
        cell.imgView.image = nil
        if let picture =  orderDetail?.pictures?[indexPath.row] {
            cell.nameLabel.text = picture.name
            if ReachabilityManager.isNetworkAvailable {
                if picture.url != nil {
                    cell.imgView.sd_setImage(with: URL(string: E(picture.urlS3)),
                                             placeholderImage: #imageLiteral(resourceName: "place_holder"),
                                             options: .refreshCached, completed: nil)
                }else {
                    cell.imgView.image = UIImage(data: picture.contentFile ?? Data())
                }
            } else {
                cell.imgView.image = UIImage(data: picture.contentFile ?? Data())
            }
        }
        
        let countPicture = orderDetail?.pictures?.count ?? 0
        if indexPath.row == (countPicture - 1) {
            cell.vContent?.roundCornersLRB()
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func cellDiscription(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: addressCellIdentifier, for: indexPath) as! OrderDetailTableViewCell
        let description = OrderDetailInforRow("Instructions".localized,"-")
        cell.orderDetailItem = description
        cell.selectionStyle = .none
        cell.vContent?.roundCornersLRB()
        
        return cell
    }
}

extension OrderDetailViewController:DMSNavigationServiceDelegate {
    func didSelectedMenuAction() {
        showSideMenu()
    }
    
    func didSelectedBackAction() {
        popViewController()
    }
}

//MARK: - OrderDetailSKUCellDelegate
extension OrderDetailViewController: OrderDetailSKUCellDelegate {
    func didEnterDeliveredQuantityTextField(_ cell: OrderDetailSKUCell, value: String, detail: Order.Detail) {
        guard let _order = orderDetail else { return }
        let inputQty = Int(value)
        tempActualQty.updateValue(inputQty ?? 0, forKey: detail.pivot?.id ?? 0)
        if _order.isNewStatus {
            detail.pivot?.loadedQty = inputQty
        } else {
            detail.pivot?.deliveredQty = inputQty
            if let _deliverQty = inputQty, let _loadedQty = detail.pivot?.loadedQty {
                detail.pivot?.returnedQty = _loadedQty - _deliverQty
            }
        }
    }
}


//MARK: - OrderDetailTableViewCellDelegate
extension OrderDetailViewController: OrderDetailTableViewCellDelegate {
    
    func didEnterPalletsQuantityTextField(_ cell: OrderDetailTableViewCell, value: String, detail:Order.Detail) {
//        guard let _order = orderDetail else { return }
//        let inputQty = Int(value)
//        if _order.isNewStatus {
//            detail.loadedQty = inputQty
//        } else {
//            detail.actualQty = inputQty
//        }
    }
    
    func didEnterCartonsQuantityTextField(_ cell: OrderDetailTableViewCell, value: String, detail:Order.Detail) {
//        guard let _order = orderDetail else { return }
//        let inputQty = Int(value)
//        if _order.isDeliveryType {
//            detail.actualCartonsInPallet = inputQty
//        } else {
//            if _order.isNewStatus {
//                detail.loadedCartonsInPallet = inputQty
//            } else {
//                detail.actualCartonsInPallet = inputQty
//            }
//        }
    }
    
    func didSelectGo(_ cell: OrderDetailTableViewCell, _ btn: UIButton) {
        let vc:StartRouteOrderVC = StartRouteOrderVC.loadSB(SB: .Route)
        vc.order  = orderDetail
        vc.callback = {[weak self](success, order) in
            self?.orderDetail = order
            self?.fetchData(showLoading: false)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didSelectedDopdown(_ cell: OrderDetailTableViewCell, _ btn: UIButton) {
        //
    }
    
    func didSelectEdit(_ cell: OrderDetailTableViewCell, _ btn: UIButton) {
        guard let orderSection = OrderDetailSection(rawValue:btn.tag) else {
            return
        }
        switch orderSection {
        case .sectionPictures:
            doAddPictures()
        case .sectionSignature:
            doAddSignature()
//        case .sectionAddNote:
//            redirectToAddNoteVC()
        default:
            break
        }
    }
    
    func redirectToAddNoteVC() {
        let vc:NoteManagementViewController = .loadSB(SB: .Common)
        vc.order = orderDetail
        vc.notes = orderDetail?.notes ?? []
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func doAddSignature()  {
        let viewController = SignatureViewController()
        viewController.isFromOrderDetail = true
        viewController.delegate = self
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    func doAddPictures() {
        ImagePickerView.shared().showImageGallarySinglePick(atVC: self) {[weak self] (success, data) in
            if data.count > 0{
                self?.uploadMultipleFile(files: data)
            }
        }
    }
}


//MARK: - SignatureViewControllerDelegate
extension OrderDetailViewController:SignatureViewControllerDelegate{
    func signatureViewController(view: SignatureViewController, didCompletedSignature signature: AttachFileModel?, signName:String?) {
        if let sig = signature {
            submitSignature(sig, signName ?? "")
        }
    }
}


//MARK: - Otherfuntion
fileprivate extension OrderDetailViewController{
    private func handleUnableToStartAction() {
        let vc:ReasonListViewController = .loadSB(SB: .Common)
        vc.orderDetail = orderDetail
        vc.didCancelSuccess =  { [weak self] (success, order) in
            //self?.fetchData(showLoading: false)
            self?.orderDetail = order as? Order
            self?.updateUI()
            self?.setupDataDetailInforRows()
            self?.tableView?.reloadData()
            self?.didUpdateStatus?((self?.orderDetail)!, nil)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleFinishAction() {
        guard let _orderDetail = orderDetail, let detail = _orderDetail.details?.first else {return}
//        let actualQty = _orderDetail.details?.first?.actualQty
        if _orderDetail.isRequireImage() &&
            _orderDetail.pictures?.count ?? 0 <= 0{
            self.showAlertView("picture-required".localized) {(action) in
                //self?.didUpdateStatus?(_orderDetail, nil)
            }
            
        }else if (_orderDetail.isRequireSign() &&
            _orderDetail.signature == nil) {
            self.showAlertView("signature-required".localized) {(action) in
                //self?.didUpdateStatus?(_orderDetail, nil)
            }
            
        } else if (!_orderDetail.isValidAllDeliveredQty) {
            let mes = "delivered-quantity-must-be-less-than-or-equal-the-loaded-quantity".localized
            showAlertView(mes)
        } else {
            
            let statusNeedUpdate = _orderDetail.getDeliveredStatusWithDeliveredQuantity()
            if statusNeedUpdate == .PartialDelivered {
                self.showReturnReasonView { (reason) in
                    self.updateOrderStatus(statusNeedUpdate.rawValue,cancelReason: reason)
                }
            } else {
                self.updateOrderStatus(statusNeedUpdate.rawValue)
            }
        }
            
    }
    
//    private func handleReturnedPalletAction() {
//        guard let detail = orderDetail?.details?.first else {return}
//        let statusNeedUpdate = detail.getFinishedStatusWithInputQuantity()
//        self.updateOrderStatus(statusNeedUpdate.rawValue,updateDetailType:.ReturnedPallet)
//    }
    
    private func showInputNote(_ statusNeedUpdate:String) {
        let alert = UIAlertController(title: "finish-order".localized,
                                      message: nil, preferredStyle: .alert)
        alert.showTextViewInput(placeholder: "enter-note-for-this-orderoptional".localized,
                                nameAction: "Finish".localized,
                                oldText: "") {[weak self] (success, string) in
                                    //self?.orderDetail?.note = string
                                    self?.updateOrderStatus(statusNeedUpdate)
        }
    }
    
    private func callPhone(phone:String) {
        if !isEmpty(phone){
            let urlString = "tel://\(phone)"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }else {
            print("phone-number-is-invalid".localized)
        }
    }
    
    private func scrollToBottom(){
        DispatchQueue.main.async {[weak self] in
            let indexPath = IndexPath(row: 0, section: OrderDetailSection.sectionDescription.rawValue)
            self?.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    private func handleShowingUnableToStartButton() {
        var isHiddenUnableToStartButton = true
        if orderDetail?.status?.code == StatusOrder.InTransit.rawValue || (orderDetail?.isNewStatus ?? false) {
            isHiddenUnableToStartButton = false
        }
        unableToStartButton.isHidden = isHiddenUnableToStartButton
    }
    
    private func handleShowingButtonStatus() {
        guard let _order = orderDetail, let _route = route else { return }
        handleShowingUnableToStartButton()
        updateStatusButton?.isEnabled = true
        switch orderDetail?.statusOrder.rawValue {
        case StatusOrder.newStatus.rawValue:
            let title = _order.isPickUpType ? "picked-up".localized : "Load".localized
            updateStatusButton?.setTitle(title.uppercased(), for: .normal)
            updateStatusButton?.backgroundColor = AppColor.pickedUpStatus
            
            unableToStartButton?.setTitle("cancel".localized.uppercased(), for: .normal)
            break
        case StatusOrder.InTransit.rawValue:
            updateStatusButton?.setTitle("Deliver".localized.uppercased(), for: .normal)
            updateStatusButton?.backgroundColor = AppColor.greenColor
            
            unableToStartButton?.setTitle("unable-to-deliver".localized.uppercased(), for: .normal)
            break
        case StatusOrder.deliveryStatus.rawValue, StatusOrder.PartialDelivered.rawValue :
            updateStatusButton?.setTitle("request-more-legs".localized.uppercased(), for: .normal)
            updateStatusButton?.backgroundColor = AppColor.greenColor
            break
        default:
            let title = _order.isPickUpType ? "back-to-warehouse".localized : "go-to-delivery".localized
            updateStatusButton?.setTitle(title.uppercased(), for: .normal)
            updateStatusButton?.backgroundColor = AppColor.greenColor
        }
        
        let isHidden = _order.isCancelled || (!isHaveMoreLegs && _order.isFinished)
        
        updateStatusButton?.isHidden = isHidden
        copyUpdateStatusButton()
        vAction?.isHidden = isHidden

    }
    
    private func copyUpdateStatusButton() {
        shortcutUpdateStatusButton?.isEnabled = updateStatusButton?.isEnabled ?? true
        shortcutUpdateStatusButton?.isHidden = updateStatusButton?.isHidden ?? true
        if updateStatusButton?.isEnabled == false {
            shortcutUpdateStatusButton?.isHidden = true
        }
        shortcutUpdateStatusButton?.backgroundColor = updateStatusButton?.backgroundColor
        let title = updateStatusButton?.title(for: .normal)
        shortcutUpdateStatusButton?.setTitle(title, for: .normal)
    }
    
    private func handleShowingButtonStatusWithPickedUpType() {
        guard let _order = orderDetail else { return }
        handleShowingUnableToStartButton()
        updateStatusButton?.isEnabled = true
        switch orderDetail?.statusOrder.rawValue {
        case StatusOrder.newStatus.rawValue:
            updateStatusButton?.setTitle("picked-up".localized.uppercased(), for: .normal)
            updateStatusButton?.backgroundColor = AppColor.pickedUpStatus
            
            unableToStartButton?.setTitle("cancel".localized.uppercased(), for: .normal)
            break
        case StatusOrder.InTransit.rawValue:
            updateStatusButton?.setTitle("Deliver".localized.uppercased(), for: .normal)
            updateStatusButton?.backgroundColor = AppColor.greenColor
            
            unableToStartButton?.setTitle("unable-to-deliver".localized.uppercased(), for: .normal)
            break
        case StatusOrder.deliveryStatus.rawValue, StatusOrder.PartialDelivered.rawValue:
            updateStatusButton?.setTitle("request-more-legs".localized.uppercased(), for: .normal)
            updateStatusButton?.backgroundColor = AppColor.mainColor
        default:
            updateStatusButton?.isHidden = true
            shortcutUpdateStatusButton?.isHidden = true
            vAction?.isHidden = true
            return
        }

//        let isHidden = (_order.isCancelled || _order.isFinished)
        let isHidden = _order.isCancelled
        updateStatusButton?.isHidden = isHidden
        copyUpdateStatusButton()
        vAction?.isHidden = isHidden
        
    }
    
    private func updateButtonStatus() {
        guard let _order = orderDetail else { return }
//        if _order.isPickUpType {
//            handleShowingButtonStatusWithPickedUpType()
//        } else {
//            handleShowingButtonStatusWithDeliveryType()
//        }
        handleShowingButtonStatus()
    }
    
    private func getAssetThumbnail(asset: PHAsset, size: CGFloat) -> UIImage {
        let retinaScale = UIScreen.main.scale
        let retinaSquare = CGSize(width: size * retinaScale, height: size * retinaScale)
        
        let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
        let square = CGRect(x: 0, y: 0, width: CGFloat(cropSizeLength), height:  CGFloat(cropSizeLength))
        
        let cropRect = square.applying(CGAffineTransform(scaleX: 1.0/CGFloat(asset.pixelWidth), y: 1.0/CGFloat(asset.pixelHeight)))
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        var thumbnail = UIImage()
        
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.normalizedCropRect = cropRect
        
        manager.requestImage(for: asset, targetSize: retinaSquare, contentMode: .aspectFit, options: options, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
}

//MARK: API
extension OrderDetailViewController{
    func fetchData(showLoading:Bool = false)  {
        self.getOrderDetail()
    }
    
    private func getOrderDetail(isFetch:Bool = false) {
        if ReachabilityManager.isNetworkAvailable {
            guard let _orderID = orderDetail?.id else { return }
            if !isFetch {
                showLoadingIndicator()
            }
            SERVICES().API.getOrderDetail(orderId: "\(_orderID)") {[weak self] (result) in
                self?.dismissLoadingIndicator()
                switch result{
                case .object(let object):
                    guard let _orderDetail = object.data else { return }
                    self?.orderDetail = _orderDetail
                    self?.rootVC?.order =  self?.orderDetail
                    self?.initVar()
                    self?.updateUI()
                    CoreDataManager.updateOrderDetail(_orderDetail) // update orderdetail to DB local
                    if _orderDetail.isFinished {
                        self?.requestMoreLegs(orderID: _orderDetail.id)
                    }
                case .error(let error):
                    self?.showAlertView(error.getMessage())
                }
            }
            
        }else {
            //Get data from local DB
             if let _order = self.orderDetail{
                CoreDataManager.queryOrderDetail(_order.id, callback: {[weak self] (success,data) in
                    guard let strongSelf = self else{return}
                    strongSelf.orderDetail = data
                    strongSelf.initVar()
                    strongSelf.updateUI()
                })
             }
        }
    }
    
    func updateOrderStatus(_ statusCode: String, updateDetailType:Order.Detail.DetailUpdateType = .Deliver, cancelReason:Reason? = nil, reasonMessage:String? = nil) {
        guard let _orderDetail = orderDetail else {
            return
        }
        
        let oldStatusCode = _orderDetail.status!.code!
        let newStatus = CoreDataManager.getStatus(withCode: statusCode)
        _orderDetail.status = newStatus

        
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        updateOrderStatusImport(_orderDetail, oldStatusCode:oldStatusCode, updateDetailType:updateDetailType, cancelReason: cancelReason, reasonMessage: reasonMessage)
    }
    
    
    func updateOrderStatusImport(_ order:Order, oldStatusCode:String, updateDetailType:Order.Detail.DetailUpdateType = .Deliver, cancelReason:Reason? = nil, reasonMessage:String? = nil)  {
        var partialDeliveredReasonMsg = reasonMessage
        if order.statusOrder == .PartialDelivered && updateDetailType == .Deliver {
            if let mes = order.partialDeliveredReason?.message {
                partialDeliveredReasonMsg = mes
            }
        }
        
        SERVICES().API.updateOrderStatus(order, reason:cancelReason, updateDetailType:updateDetailType, partialDeliveredReasonMsg: partialDeliveredReasonMsg) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.updateOrderStatusInRoute(orderID: order.id, status: order.status!)
                self?.setupDataDetailInforRows()
                self?.updateButtonStatus()
                self?.tableView?.reloadData()
                self?.tableView?.setContentOffset(.zero, animated: true)
                
                if order.isFinished {
                    self?.requestMoreLegs(orderID: order.id)
                }
                
                self?.didUpdateStatus?(order, nil)
                
            case .error(let error):
                let oldStatus = CoreDataManager.getStatus(withCode: oldStatusCode)
                order.status = oldStatus
                self?.updateButtonStatus()
                self?.showAlertView(error.getMessage(), completionHandler: { (action) in
                    self?.fetchData(showLoading: true)
                })
            }
        }
    }
    
    func updateOrderStatusInRoute(orderID:Int, status:Status) {
        route?.updateOrder(orderID: orderID, toStatus: status)
    }
    
    func submitSignature(_ file: AttachFileModel,_ name:String) {
        guard let order = orderDetail else { return }
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        SERVICES().API.submitSignature(file,order,name) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.fetchData()
                
            case .error(let error):
                self?.showAlertView(error.getMessage(), completionHandler: { (action) in
                    self?.fetchData(showLoading: true)
                })
                break
            }
        }
    }
    
    func uploadMultipleFile(files:[AttachFileModel]){
        guard let order = orderDetail else { return }
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        SERVICES().API.uploadMultipleImageToOrder(files, order) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.fetchData()
                
            case .error(let error):
                self?.showAlertView(error.getMessage(), completionHandler: { (action) in
                    self?.fetchData(showLoading: true)
                })
            }
        }
    }
    
    func updateRoute()  {
        for i in 0..<(self.route?.orderList.count ?? 0) {
            if self.route?.orderList[i].id == self.orderDetail?.id {
                self.route?.orderList[i] = (self.orderDetail)!
                break
            }
        }
    }
    
    func assignOrderToDriver(_ requestAssignOrder:RequestAssignOrderModel)  {
        self.showLoadingIndicator()
        SERVICES().API.assignOrderToDriver(body: requestAssignOrder) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.updateOrderDetail?(self?.orderDetail)
                self?.showAlertView("assigned-successfull".localized,
                                    completionHandler: { (ok) in
                })
                
            case .error(let error):
                self?.showAlertView(error.getMessage(), completionHandler: { (action) in
                    self?.fetchData(showLoading: true)
                })
            }
        }
    }
    
    func requestMoreLegs(orderID: Int) {
        if ReachabilityManager.isNetworkAvailable {
            self.showLoadingIndicator()
            SERVICES().API.checkMoreLegs(orderID) { [weak self] (result)in
                self?.dismissLoadingIndicator()
                switch result {
                case .object(let object):
                    self?.isHaveMoreLegs = object.data
                    self?.handleShowingButtonStatus()
                case .error(let error):
                    self?.showAlertView(error.getMessage(), completionHandler: { (action) in
                        self?.fetchData(showLoading: true)
                    })
                }
            }
        }
    }
    
    func uploadRequestMoreOrderWith(_ amount: Int) {
        self.showLoadingIndicator()
        guard let order = orderDetail else { return }
        SERVICES().API.requestMoreLegs(order.id, legs: amount) { [weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result {
            case .object(_):
                self?.showAlertView(MSG_UPDATED_SUCCESSFUL, completionHandler: { (action) in
                    self?.popViewController()
                })
            case .error(let error):
                self?.showAlertView(error.getMessage(), completionHandler: { (action) in
                    self?.fetchData(showLoading: true)
                })
            }
        }
    }
}

