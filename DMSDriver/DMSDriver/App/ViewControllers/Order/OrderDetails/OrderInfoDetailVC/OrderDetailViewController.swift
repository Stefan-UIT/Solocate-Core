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
    @IBOutlet weak var btnUnable: UIButton?
    @IBOutlet weak var vAction: UIView?
    @IBOutlet weak var lblOrderId: UILabel?
    @IBOutlet weak var lblDateTime: UILabel?
    @IBOutlet weak var unableToStartButton: UIButton!
    
    fileprivate var orderInforDetail = [OrderDetailInforRow]()
    fileprivate var orderInforFrom = [OrderDetailInforRow]()
    fileprivate var orderInforTo = [OrderDetailInforRow]()
    fileprivate var orderCODInfo = [OrderDetailInforRow]()
    fileprivate var orderInforNatureOfGoods = [OrderDetailInforRow]()
    fileprivate let cellIdentifier = "OrderDetailTableViewCell"
    fileprivate let headerCellIdentifier = "OrderDetailHeaderCell"
    fileprivate let addressCellIdentifier =  "OrderDetailAddressCell"
    fileprivate let orderDropdownCellIdentifier = "OrderDetailDropdownCell"
    fileprivate let orderDetailMapCellIdentifier = "OrderDetailMapCell"
    fileprivate let orderPictureTableViewCell = "PictureTableViewCell"
    fileprivate let orderDetailNatureOfGoodsCell = "OrderDetailNatureOfGoodsCell"

    fileprivate var arrTitleHeader:[String] = []
    fileprivate let heightHeader:CGFloat = 65
    
    var dateStringFilter = Date().toString()
    var btnGo: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        fetchData(showLoading: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                          "packgages".localized.uppercased(),
                          "Signature".localized.uppercased(),
                          "Picture".localized.uppercased(),
//                          "add-note".localized.uppercased()
        ]
        setupDataDetailInforRows()
    }
    
    private func initUI()  {
        self.setupTableView()
        lblOrderId?.text = "order".localized + " #\(orderDetail?.id ?? 0)"
        guard  let start = orderDetail?.to?.start_time?.date,
               let end = orderDetail?.to?.end_time?.date else{
            lblDateTime?.text = "Start/End-time is invalid".localized
            return
        }
        let timeStart = DateFormatter.hour24Formater.string(from: start)
        let timeEnd = DateFormatter.hour24Formater.string(from: end)
        let date = DateFormatter.shortDate.string(from: end)
        lblDateTime?.text = "\(timeStart) - \(timeEnd) \(date)"
    }
    
    private func setupDataDetailInforRows() {
        orderInforDetail.removeAll()
        orderInforFrom.removeAll()
        orderInforTo.removeAll()
        orderInforNatureOfGoods.removeAll()
        orderCODInfo.removeAll()
        
        guard let order = orderDetail else { return }
//        let displayDateTimeVN = DateFormatter.displayDateTimeVN
//        var startFromDate = ""
//        if let date = order.from?.start_time?.date {
//            startFromDate = displayDateTimeVN.string(from: date)
//        }else {
//            startFromDate = "invalid-date".localized
//        }
//
//        var endFromDate = ""
//        if let date = order.from?.end_time?.date {
//            endFromDate = displayDateTimeVN.string(from: date)
//        }else {
//            endFromDate = "invalid-date".localized
//        }
//
//        var startToDate = ""
//        if let date = order.to?.start_time?.date {
//            startToDate = displayDateTimeVN.string(from: date)
//        }else {
//            startToDate = "invalid-date".localized
//        }
//
//        var endToDate = ""
//        if let date = order.to?.end_time?.date {
//            endToDate = displayDateTimeVN.string(from: date)
//        }else {
//            endToDate = "invalid-date".localized
//        }
        
        let startFromDate = Slash(order.from?.start_time)
        let endFromDate = Slash(order.from?.end_time)
        
        let startToDate = Slash(order.to?.start_time)
        let endToDate = Slash(order.to?.end_time)
        
        let customerItem = OrderDetailInforRow("customer-name".localized,
                                             Slash(order.customer?.userName))
//        let urgency = OrderDetailInforRow("Urgency".localized,
//                                          isHebewLang() ? order.urgent_type_name_hb ?? "" :  order.urgent_type_name_en ?? "")
        let orderId = OrderDetailInforRow("order-id".localized,"#\(order.id)")
//        let seq = OrderDetailInforRow("SEQ".localized,"\(order.seq ?? 0)")
        
        //NEW
        let orderGroup = OrderDetailInforRow("order-group".localized,order.orderGroup.name)
        let orderType = OrderDetailInforRow("order-type".localized,order.orderType.name)
        

        orderInforDetail.append(orderId)
//        orderInforDetail.append(seq)
        orderInforDetail.append(orderGroup)
        orderInforDetail.append(orderType)
        orderInforDetail.append(customerItem)
        //orderInforStatus.append(urgency)
        
        if  (order.statusOrder == .CancelStatus ||
             order.statusOrder == .UnableToFinish),
            let _orderDetail = orderDetail{
            let reason = OrderDetailInforRow("failure-cause".localized,_orderDetail.reason?.name ?? "-")
            let mess = OrderDetailInforRow("Message".localized,_orderDetail.reason_msg ?? "-")
            orderInforDetail.append(reason)
            orderInforDetail.append(mess)
        }
        
        let fromLocationName = OrderDetailInforRow("location-name".localized, Slash(order.from?.loc_name),false)
        let fromAddress = OrderDetailInforRow("Address".localized, E(order.from?.address),true)
        let fromContactName = OrderDetailInforRow("contact-name".localized,order.from?.name ?? "-")
        let fromContactPhone = OrderDetailInforRow("contact-phone".localized,order.from?.phone ?? "-",true)
        let fromStartTime = OrderDetailInforRow("start-time".localized,startFromDate,false)
        let fromEndtime = OrderDetailInforRow("end-time".localized,endFromDate,false)
        let fromServiceTime = OrderDetailInforRow("service-time".localized,Slash(order.from?.serviceTime),false)
        let fromFloor = Slash(order.from?.floor)
        let fromApartment = Slash(order.from?.apartment)
        let fromNumber = Slash(order.from?.number)
        
        let fromAddressDetail = "\(fromFloor)/\(fromApartment)/\(fromNumber)"
        let fromAddressDetailRecord = OrderDetailInforRow("Floor/Apt/Number",fromAddressDetail,false)

        let toAddress = OrderDetailInforRow("Address".localized, E(order.to?.address),true)
        let toContactName = OrderDetailInforRow("contact-name".localized,order.to?.name ?? "-")
        let toContactPhone = OrderDetailInforRow("contact-phone".localized,order.to?.phone ?? "-", true)
        let toStartTime = OrderDetailInforRow("start-time".localized,startToDate,false)
        let tomEndtime = OrderDetailInforRow("end-time".localized,endToDate,false)
        let toLocationName = OrderDetailInforRow("location-name".localized, Slash(order.to?.loc_name),false)
        let toServiceTime = OrderDetailInforRow("service-time".localized,Slash(order.to?.serviceTime),false)
        
        let toFloor = Slash(order.to?.floor)
        let toApartment = Slash(order.to?.apartment)
        let toNumber = Slash(order.to?.number)
        
        let toAddressDetail = "\(toFloor)/\(toApartment)/\(toNumber)"
        let toAddressDetailRecord = OrderDetailInforRow("Floor/Apt/Number",toAddressDetail,false)
        
        let codAmount = OrderDetailInforRow("COD Amount".localized,"\(order.codAmount ?? 0)",false)
        let codRemark = OrderDetailInforRow("COD Remark".localized,Slash(order.codComment),false)
        
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
        ReasonSkipView.show(inView: self.view) {[weak self] (success, reason) in
            guard let _reason = reason else {return}
            self?.cancelOrder(reason: _reason, isUnableToFinish: isUnableToFinish)
        }
    }
    
    func showPalletReturnedPopUp() {
        let alert = UIAlertController(title: "Returned Pallets", message: "Number of returned pallets", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "submit".localized, style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let returnedPalletQty = Int(textField?.text ?? "0")!
            if let detail = self.orderDetail?.details?.first {
                detail.returnedPalletQty = returnedPalletQty
            }
            self.handleReturnedPalletAction()
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: {
            action in
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showReasonMessage(completionHandler:@escaping (_ reason:String)->Void) {
        let alert = UIAlertController(title: "Reason",
                                      message: nil, preferredStyle: .alert)
        alert.showTextViewInput(placeholder: "Please enter a reason for Partial\nDelivered",
                                nameAction: "submit".localized,
                                oldText: "") {(success, string) in
                                    //self?.orderDetail?.note = string
                                    completionHandler(string)
        }
    }
    
    
    func showReasonMessagePopup(completionHandler:@escaping (_ reason:String)->Void) {
        let title = "Reason"
        let message = "Please enter a reason for Partial Delivered"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "submit".localized, style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            guard let text = textField?.text, !text.isEmpty else {
                self.showAlertView("You must enter a reason for Partial Delivered")
                return
            }
            
            completionHandler(text)
            
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: {
            action in
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func showCODPopUp() {
        guard let codAmount = orderDetail?.codAmount else { return }
        let title = "COD Received"
        let message = "Did you receive COD amount $\(codAmount)?"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.keyboardType = .decimalPad
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "submit".localized, style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            guard let text = textField?.text, let value = Double(text), value <= codAmount && value > 0.0  else {
                self.showAlertView("COD must be less than or equal $\(codAmount)")
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
//                let statusNeedUpdate = StatusOrder.deliveryStatus.rawValue
//                self?.updateOrderStatus(statusNeedUpdate)
                self?.handleFinishAction()
            case .error(let error):
                self?.showAlertView(error.description)
            }
        }
    }
    
    private func handleUpdateStatusWithDeliveryType() {
        switch orderDetail?.statusOrder.rawValue {
        case StatusOrder.newStatus.rawValue:
            showReasonView(isUnableToFinish: false)
            break
        case StatusOrder.deliveryStatus.rawValue, StatusOrder.PartialDelivered.rawValue:
            showPalletReturnedPopUp()
            break
            
        case StatusOrder.Loaded.rawValue, StatusOrder.PartialLoaded.rawValue:
            App().showAlertView("do-you-want-to-start-this-order".localized,
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
        default:
            break
        }
    }
    
    private func handleUpdateStatusWithPickedUpType() {
        guard let _order = orderDetail, let detail = _order.details?.first else { return }
        switch orderDetail?.statusOrder.rawValue {
        case StatusOrder.newStatus.rawValue:
            self.submitPickedUpQuantity(detail: detail)
            break
        case StatusOrder.InTransit.rawValue:
            handleFinishAction()
            break
        default:
            break
        }
    }
    
    func submitPickedUpQuantity(detail:Order.Detail) {
        if let loadedQty = detail.loadedQty, let qty = detail.qty, loadedQty <= qty {
            if (detail.isPallet) {
                if let loadedCartons = detail.loadedCartonsInPallet {
                    let cartons = detail.cartonsInPallet ?? 0
                    if loadedCartons <= cartons {
                        updatePickedUpQuantity(detail:detail)
                        return
                    }
                }
                showAlertView("Picked up cartons quantity must be less than or equal \(detail.cartonsInPallet ?? 0)")
                return
            }
            updatePickedUpQuantity(detail:detail)
            // call without loaded carton
        } else {
            showAlertView("Picked up quantity must be less than or equal \(detail.qty ?? 0)")
            return
        }
    }
    
    func updatePickedUpQuantity(detail:Order.Detail) {
        let status = StatusOrder.InTransit.rawValue
        updateOrderStatus(status,updateDetailType: .Load)
    }
    
    // MARK: - ACTION
    @IBAction func tapUpdateStatusButtonAction(_ sender: UIButton) {
        guard let _order = orderDetail else { return }
        if _order.isPickUpType {
            handleUpdateStatusWithPickedUpType()
        } else {
            handleUpdateStatusWithDeliveryType()
        }
    }
    
    
    @IBAction func onUnableToStartTouchUp(_ sender: UIButton) {
        showReasonView(isUnableToFinish: true)
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
            return 1
        case .sectionOrderInfo:
            return orderInforDetail.count
        case .sectionFrom:
            return orderInforFrom.count
        case .sectionTo:
            return orderInforTo.count
        case .sectionCOD:
            return (_orderDetail.isHasCOD) ? orderCODInfo.count : 0
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
            return (_orderDetail.isHasCOD) ? heightHeader : CGFloat.leastNormalMagnitude
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
            
            let statusesShouldAllowToSignAndUpload = (orderDetail?.statusOrder == StatusOrder.InTransit || orderDetail?.statusOrder == StatusOrder.deliveryStatus || orderDetail?.statusOrder == StatusOrder.PartialDelivered)
            
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
//                var isAdd = false
//                if (orderDetail?.signature == nil &&
//                    orderDetail?.route?.driverId == Caches().user?.userInfo?.id){
                let hasSigned = orderDetail?.signature != nil
                let isHidden = hasSigned || !statusesShouldAllowToSignAndUpload
                headerCell.btnEdit?.isHidden = isHidden
            case .sectionPictures:
//                if orderDetail?.route?.driverId == Caches().user?.userInfo?.id &&
//                        (orderDetail?.statusOrder == StatusOrder.newStatus ||
//                         orderDetail?.statusOrder == StatusOrder.InTransit ||
//                         orderDetail?.statusOrder == StatusOrder.PickupStatus){
//                    isAdd = true
//                }
                headerCell.btnEdit?.isHidden = !statusesShouldAllowToSignAndUpload
//            case .sectionAddNote:
//                headerCell.btnEdit?.isHidden = false
                
                case .sectionCOD:
                    if !_orderDetail.isHasCOD {
                        return nil
                    }
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
        if orderSection == OrderDetailSection.sectionCOD && !_orderDetail.isHasCOD {
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
            return cellNatureOfGood(tableView,indexPath)
        case .sectionSignature:
            return cellSignature(tableView, indexPath)
        case .sectionPictures:
            return cellPicture(tableView,indexPath)
        case .sectionDescription:
           return cellDiscription(tableView,indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let orderSection = OrderDetailSection(rawValue:indexPath.section) else {
            return
        }
        let row = indexPath.row
        switch orderSection {
        case .sectionFrom:
            if row != 0 &&  // from-address, contact-phone
                row != orderInforFrom.count - 3 {
                return
            }
            
            if row == 0{ //from-address
                let vc:OrderDetailMapViewController = .loadSB(SB: .Order)
                vc.orderDetail = orderDetail
                if let _orderDetail = orderDetail,
                    let lng = _orderDetail.from?.lngtd,
                    let lat = _orderDetail.from?.lattd  {
                    let location = CLLocationCoordinate2D(latitude: lat.doubleValue ,
                                                          longitude: lng.doubleValue)
                    vc.orderLocation = location
                }
                
                self.navigationController?.pushViewController( vc, animated: true)

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
                let vc:OrderDetailMapViewController = .loadSB(SB: .Order)
                vc.orderDetail = orderDetail

                if let _orderDetail = orderDetail,
                    let lng = _orderDetail.to?.lngtd,
                    let lat = _orderDetail.to?.lattd  {
                    let location = CLLocationCoordinate2D(latitude: lat.doubleValue ,
                                                          longitude: lng.doubleValue)
                    vc.orderLocation = location
                }
                self.navigationController?.pushViewController( vc, animated: true)
                
            }else {
                let item = orderInforTo[row]
                callPhone(phone: item.content)
            }
            
        case .sectionSignature:
            self.showImage(nil, linkUrl: orderDetail?.signature?.url, placeHolder: nil)
            
        case .sectionPictures:
            let picture = orderDetail?.pictures?[row]
            self.showImage(nil, linkUrl: picture?.url, placeHolder: nil)
            
        default:
            break
        }
    }
}

//MARK:  - UIScrollViewDelegate
extension OrderDetailViewController:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if orderDetail?.statusOrder != StatusOrder.newStatus &&
            orderDetail?.statusOrder != StatusOrder.InTransit {
            return
        }
        
        let offsetY = scrollView.contentOffset.y
        print("OffsetY :\(offsetY)")
        UIView.animate(withDuration: 0.7, animations: {
            if offsetY > 45 {
                self.vAction?.isHidden = false
                self.btnGo?.isHidden = true
            }else {
                self.vAction?.isHidden = true
                self.btnGo?.isHidden = false
            }
           self.vAction?.layoutIfNeeded()
            
        }) { (finished) in
            //
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
    
    func cellNatureOfGood(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let cell = tableView.dequeueReusableCell(withIdentifier: orderDetailNatureOfGoodsCell,
                                                    for: indexPath) as! OrderDetailTableViewCell
        cell.selectionStyle = .none
        guard let order = orderDetail, let detail = order.details?[indexPath.row] else { return cell }
        let barCode = detail.barCode ?? ""
        let paRefId = ((detail.packageRefId) != nil) ? "\((detail.packageRefId)!)" : ""
        cell.detail = detail
        cell.nameLabel?.text = detail.package?.name
        cell.contentLabel?.text = "\(detail.qty ?? 0)"
        cell.lblBarcode?.text = barCode
        cell.lblPackgage?.text = paRefId
        cell.loadedQuantityLabel?.text = IntSlash(detail.loadedQty)
        cell.loadedCartonsLabel?.text = IntSlash(detail.loadedCartonsInPallet)
        cell.returnedPalletsLabel?.text = IntSlash(detail.returnedPalletQty)
        
        let isPickUpAndNewOrder = order.isPickUpType && order.isNewStatus
        cell.actualQuantityTextField?.text = (isPickUpAndNewOrder) ? "\(detail.loadedQty ?? 0)" : "\(detail.actualQty!)"
        cell.vContent?.cornerRadius = 0
        cell.delegate = self
        if indexPath.row == (orderDetail?.details?.count ?? 0 ) - 1{
            cell.vContent?.roundCornersLRB()
        }
        
        func hideLoadedQuantityContainer() {
            cell.loadedQtyViewContainer?.isHidden = true
            cell.loadedQtyTopSpaceConstraint?.constant = 0.0
            cell.loadedQtyContainerHeightConstraint?.constant = 0.0
        }
        
        if order.isPickUpType {
            cell.deliveredQtyStaticLabel?.text = (order.isNewStatus) ? "Picked Up Quantity" : "Delivered Quantity"
            cell.deliveredCartonsStaticLabel?.text = (order.isNewStatus) ? "Picked Up Cartons Qty" : "Delivered Cartons Quantity"
            hideLoadedQuantityContainer()
        } else {
            if !detail.isPallet {
                cell.loadedCartonsQtyViewContainer?.isHidden = true
                cell.loadedQtyContainerHeightConstraint?.constant = 22.0
            }
        }
        
        let isShowingOnly = order.isDeliveryType && (order.statusOrder == StatusOrder.newStatus || order.statusOrder == StatusOrder.Loaded || order.statusOrder == StatusOrder.PartialLoaded || order.statusOrder == StatusOrder.WarehouseClarification || order.statusOrder == StatusOrder.CancelStatus)
        
        func handleEnablingTextField() {
            if order.isDeliveryType {
                let isEnabled = order.statusOrder == StatusOrder.InTransit
                cell.actualQuantityTextField?.isEnabled = isEnabled
                cell.actualCartonsInPalletTextField?.isEnabled = isEnabled
            } else {
                let isEnabled = order.isNewStatus || order.isInTransit
                cell.actualQuantityTextField?.isEnabled = isEnabled
                cell.actualCartonsInPalletTextField?.isEnabled = isEnabled
            }
        }
        
        func handleShowingPalletSection() {
            cell.handleShowingDeliveredQtyRecored(isHidden: isShowingOnly)
            cell.palletsViewContainerHeightConstraint?.constant = (isShowingOnly) ? 20.0 : 50.0
        }
        
        func handleShowingCartonSection() {
            let isShowedCartonSection = detail.package?.cd == PackageE.Pallet.rawValue
            cell.cartonInPalletViewContainer?.isHidden = !isShowedCartonSection
            
            if isShowedCartonSection {
                cell.cartonInPalletsLabel?.text = "\(detail.cartonsInPallet ?? 0)"
                cell.actualCartonsInPalletTextField?.text = (isPickUpAndNewOrder) ? "\(detail.loadedCartonsInPallet ?? 0)" : "\(detail.actualCartonsInPallet ?? 0)"
                cell.handleShowingDeliveredCartonsRecord(isHidden: isShowingOnly)
                cell.cartonsViewContainerHeightConstraint?.constant = (isShowingOnly) ? 20.0 : 50.0
                cell.cartonsViewContainerTopSpacing?.constant = 6.0
                
            } else {
                cell.cartonsViewContainerHeightConstraint?.constant = 0.0
                cell.cartonsViewContainerTopSpacing?.constant = 0.0
            }
        }
        
        func handleShowingWMSCodeUI() {
            let isHidden = order.orderGroup != OrderGroup.Logistic
            cell.wmsOrderCodeViewContainer?.isHidden = isHidden
            cell.wmsMainifestNumberViewContainer?.isHidden = isHidden
            cell.wmsManifestHeightConstraint?.constant = (isHidden) ? 0.0 : 22.0
            cell.wmsOrderCodeHeightConstraint?.constant = (isHidden) ? 0.0 : 22.0
            cell.wmsOrderCodeTopSpacing?.constant = (isHidden) ? 0.0 : 6.0
            cell.wmsManifestContainerTopSpacing?.constant = (isHidden) ? 0.0 : 8.0
            cell.wmsOrderCodeLabel?.text = Slash(detail.wmsOrderCode)
            cell.wmsOrderManifestNumberLabel?.text = Slash(detail.wmsManifestNumber)
            
        }
        handleShowingWMSCodeUI()
        handleShowingPalletSection()
        handleShowingCartonSection()
        handleEnablingTextField()
        tableView.reloadSections(OrderDetailSection.sectionNatureOfGoods.indexSet, with: .automatic)
        
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
            if sig.url_thumbnail != nil {
                cell.imgView.sd_setImage(with: URL(string: E(sig.url_thumbnail)),
                                         placeholderImage: #imageLiteral(resourceName: "place_holder"),
                                         options: .refreshCached, completed: nil)
            }else {
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
            if picture.url != nil {
                cell.imgView.sd_setImage(with: URL(string: E(picture.urlS3)),
                                         placeholderImage: #imageLiteral(resourceName: "place_holder"),
                                         options: .refreshCached, completed: nil)
            }else {
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
//    func didSelectedBackOrMenu() {
//        showSideMenu()
//    }
    func didSelectedMenuAction() {
        showSideMenu()
    }
    
    func didSelectedBackAction() {
        popViewController()
    }
}


//MARK: - OrderDetailTableViewCellDelegate
extension OrderDetailViewController: OrderDetailTableViewCellDelegate {
    
    func didEnterPalletsQuantityTextField(_ cell: OrderDetailTableViewCell, value: String, detail:Order.Detail) {
        guard let _order = orderDetail else { return }
        let inputQty = Int(value)
        if _order.isDeliveryType {
            detail.actualQty = inputQty
        } else {
            if _order.isNewStatus {
                detail.loadedQty = inputQty
            } else {
                detail.actualQty = inputQty
            }
        }
    }
    
    func didEnterCartonsQuantityTextField(_ cell: OrderDetailTableViewCell, value: String, detail:Order.Detail) {
        guard let _order = orderDetail else { return }
        let inputQty = Int(value)
        if _order.isDeliveryType {
            detail.actualCartonsInPallet = inputQty
        } else {
            if _order.isNewStatus {
                detail.loadedCartonsInPallet = inputQty
            } else {
                detail.actualCartonsInPallet = inputQty
            }
        }
    }
    
    func didSelectGo(_ cell: OrderDetailTableViewCell, _ btn: UIButton) {
        let vc:StartRouteOrderVC = StartRouteOrderVC.loadSB(SB: .Route)
        vc.order  = orderDetail
        vc.callback = {[weak self](success, order) in
            self?.orderDetail = order
            self?.fetchData(showLoading: false)
            /*
            self?.setupDataDetailInforRows()
            self?.tableView?.reloadData()
            self?.updateOrderDetail?(order)
             */
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
            
        } else if (_orderDetail.details?.first?.actualQty == nil) {
            showAlertView("Delivered quantity is required")
        } else if ((_orderDetail.details?.first?.isPallet ?? false) &&  _orderDetail.details?.first?.actualCartonsInPallet == nil) {
            showAlertView("Cartons in Pallet is required")
        } else {
            
            if _orderDetail.isHasCOD && !_orderDetail.isUpdatedCODReceived {
                showCODPopUp()
                return
            }
            
            let statusNeedUpdate = detail.getFinishedStatusWithInputQuantity()
            if statusNeedUpdate == .PartialDelivered {
                self.showReasonMessage { (reason) in
                    self.updateOrderStatus(statusNeedUpdate.rawValue,reasonMessage:reason)
                }
            } else {
                self.updateOrderStatus(statusNeedUpdate.rawValue)
            }
        }
            
    }
    
    private func handleReturnedPalletAction() {
        guard let detail = orderDetail?.details?.first else {return}
        let statusNeedUpdate = detail.getFinishedStatusWithInputQuantity()
        self.updateOrderStatus(statusNeedUpdate.rawValue,updateDetailType:.ReturnedPallet)
    }
    
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
        let isHiddenUnableToStartButton = orderDetail?.status?.code != StatusOrder.InTransit.rawValue
        unableToStartButton.isHidden = isHiddenUnableToStartButton
    }
    
    private func handleShowingButtonStatusWithDeliveryType() {
        guard let _order = orderDetail else { return }
        handleShowingUnableToStartButton()
        updateStatusButton?.isEnabled = true
        switch orderDetail?.statusOrder.rawValue {
        case StatusOrder.newStatus.rawValue:
            updateStatusButton?.setTitle("cancel".localized.uppercased(), for: .normal)
            updateStatusButton?.backgroundColor = AppColor.redColor
            break
        case StatusOrder.InTransit.rawValue:
            updateStatusButton?.setTitle("Deliver".localized.uppercased(), for: .normal)
            updateStatusButton?.backgroundColor = AppColor.greenColor
            break
        case StatusOrder.deliveryStatus.rawValue, StatusOrder.PartialDelivered.rawValue:
            //            updateStatusButton?.setTitle("update-palette-return".localized.uppercased(), for: .normal)
            updateStatusButton?.setTitle("update-returned-pallets".localized.uppercased(), for: .normal)
            updateStatusButton?.backgroundColor = AppColor.greenColor
            break
            
        case StatusOrder.WarehouseClarification.rawValue:
            updateStatusButton?.setTitle("pending-on-ramp-manager-confirmation".localized.uppercased(), for: .normal)
            updateStatusButton?.isEnabled = false
            updateStatusButton?.backgroundColor = UIColor.lightGray
            break
        default:
            updateStatusButton?.setTitle("go-to-delivery".localized.uppercased(), for: .normal)
            updateStatusButton?.backgroundColor = AppColor.greenColor
        }
        let isFinishedAndNotPalletType = ((orderDetail?.statusOrder == StatusOrder.deliveryStatus || orderDetail?.statusOrder == StatusOrder.PartialDelivered) && !(orderDetail?.details?[0].isPallet)!)
        let isFinishedAndUpdatedReturnedPalletsQty = (_order.isFinished && orderDetail?.details?.first?.returnedPalletQty != nil)
        let isRampManagerAndNotNewOrder = (isRampManagerMode && orderDetail?.statusOrder != StatusOrder.newStatus)
        let isHidden = ( orderDetail?.statusOrder == StatusOrder.CancelStatus ||
            orderDetail?.statusOrder == StatusOrder.UnableToFinish || isFinishedAndNotPalletType || isFinishedAndUpdatedReturnedPalletsQty || isRampManagerAndNotNewOrder )
        
        updateStatusButton?.isHidden = isHidden
        vAction?.isHidden = isHidden

    }
    
    private func handleShowingButtonStatusWithPickedUpType() {
        guard let _order = orderDetail else { return }
        handleShowingUnableToStartButton()
        updateStatusButton?.isEnabled = true
        switch orderDetail?.statusOrder.rawValue {
        case StatusOrder.newStatus.rawValue:
            updateStatusButton?.setTitle("picked-up".localized.uppercased(), for: .normal)
            updateStatusButton?.backgroundColor = AppColor.pickedUpStatus
            break
        case StatusOrder.InTransit.rawValue:
            updateStatusButton?.setTitle("Deliver".localized.uppercased(), for: .normal)
            updateStatusButton?.backgroundColor = AppColor.greenColor
            break
        default:
            updateStatusButton?.isHidden = true
            vAction?.isHidden = true
            return
        }

        let isHidden = (_order.isCancelled || _order.isFinished)
        
        updateStatusButton?.isHidden = isHidden
        vAction?.isHidden = isHidden
        
    }
    
    private func updateButtonStatus() {
//        orderDetail?.status?.code = StatusOrder.InTransit.rawValue
//        orderDetail?.details?[0].package?.cd = "PLT"
        guard let _order = orderDetail else { return }
        if _order.isPickUpType {
            handleShowingButtonStatusWithPickedUpType()
        } else {
            handleShowingButtonStatusWithDeliveryType()
        }
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
        getOrderDetail()
    }
    
    private func getOrderDetail(isFetch:Bool = false) {
        if hasNetworkConnection &&
            ReachabilityManager.isCalling == false {
            guard let _orderID = orderDetail?.id else { return }
            if !isFetch {
                showLoadingIndicator()
            }
            SERVICES().API.getOrderDetail(orderId: "\(_orderID)") {[weak self] (result) in
                self?.dismissLoadingIndicator()
                switch result{
                case .object(let object):
                    self?.orderDetail = object.data
                    self?.rootVC?.order =  self?.orderDetail
                    self?.initVar()
                    self?.updateUI()
                    //CoreDataManager.updateOrderDetail(object) // update orderdetail to DB local
                    
                case .error(let error):
                    self?.showAlertView(error.getMessage())
                }
            }
            
        }else {
            
            //Get data from local DB
            /*
             if let _order = self.orderDetail{
             CoreDataManager.queryOrderDetail(_order.id, callback: {[weak self] (success,data) in
             guard let strongSelf = self else{return}
             strongSelf.orderDetail = data
             strongSelf.updateUI()
             })
             }
             */
        }
    }
    
    func updateOrderStatus(_ statusCode: String, updateDetailType:Order.Detail.DetailUpdateType = .Deliver, cancelReason:Reason? = nil, reasonMessage:String? = nil) {
        guard let _orderDetail = orderDetail else {
            return
        }
        let listStatus =  CoreDataManager.getListStatus()
        for item in listStatus {
            if item.code == statusCode{
                _orderDetail.status = item
                break
            }
        }
        
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        updateOrderStatusImport(_orderDetail, updateDetailType:updateDetailType, cancelReason: cancelReason, reasonMessage: reasonMessage)
    }
    
    
    func updateOrderStatusImport(_ order:Order, updateDetailType:Order.Detail.DetailUpdateType = .Deliver, cancelReason:Reason? = nil, reasonMessage:String? = nil)  {
        var partialDeliveredReasonMsg = reasonMessage
        if order.statusOrder == .PartialDelivered && updateDetailType == .ReturnedPallet {
            if let mes = order.partialDeliveredReason?.message {
                partialDeliveredReasonMsg = mes
            }
        }
        
        SERVICES().API.updateOrderStatus(order, reason:cancelReason, updateDetailType:updateDetailType, partialDeliveredReasonMsg: partialDeliveredReasonMsg) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.setupDataDetailInforRows()
                self?.updateButtonStatus()
                self?.tableView?.reloadData()
                self?.tableView?.setContentOffset(.zero, animated: true)
                self?.didUpdateStatus?(order, nil)
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
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
                self?.showAlertView(error.getMessage())
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
                self?.showAlertView(error.getMessage())
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
                                        /*
                                        let vc:JobListVC = .loadSB(SB: .Job)
                                        vc.dateStringFilter = E(self?.dateStringFilter)
                                        App().mainVC?.rootNV?.setViewControllers([vc], animated: false)
                                         */
                })
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}

