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

enum OrderDetailSection:Int {
    case sectionOrderStatus = 0
    case sectionFrom
    case sectionTo
    case sectionNatureOfGoods
    case sectionDescription
  
    static let count: Int = {
      var max: Int = 0
      while let _ = OrderDetailSection(rawValue: max) { max += 1 }
      return max
    }()
}


class OrderDetailViewController: BaseOrderDetailViewController {
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var updateStatusButton: UIButton?
    @IBOutlet weak var btnUnable: UIButton?
    @IBOutlet weak var vAction: UIView?


    fileprivate var orderInforStatus = [OrderDetailInforRow]()
    fileprivate var orderInforFrom = [OrderDetailInforRow]()
    fileprivate var orderInforTo = [OrderDetailInforRow]()
    fileprivate var orderInforNatureOfGoods = [OrderDetailInforRow]()
 
    fileprivate let cellIdentifier = "OrderDetailTableViewCell"
    fileprivate let headerCellIdentifier = "OrderDetailHeaderCell"
    fileprivate let addressCellIdentifier =  "OrderDetailAddressCell"
    fileprivate let orderDropdownCellIdentifier = "OrderDetailDropdownCell"
    fileprivate let orderDetailNatureOfGoodsCell = "OrderDetailNatureOfGoodsCell"
    fileprivate var scanItems = [String]()
    fileprivate var arrTitleHeader:[String] = []
    
    var dateStringFilter = Date().toString()
  
    override var orderDetail: Order? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        initVar()
        getOrderDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    
    override func reachabilityChangedNotification(_ notification: NSNotification) {
        super.reachabilityChangedNotification(notification)
        checkConnetionInternet?(notification, hasNetworkConnection)
    }
    
    override func updateUI()  {
        super.updateUI()
        DispatchQueue.main.async {[weak self] in
            self?.vAction?.isHidden = (self?.orderDetail == nil)
            self?.updateButtonStatus()
            self?.setupTableView()
        }
    }
    
    override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Detail".localized)
    }
    
    //MARK: - Initialize
    func setupTableView() {
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableViewAutomaticDimension
    }
    
    func initVar()  {
        arrTitleHeader = ["Order Status".localized.uppercased(),
                          "From".localized.uppercased(),
                          "To".localized.uppercased(),
                          "Nature of goods".localized.uppercased(),
                          "Instructions".localized.uppercased()]
        
        setupDataDetailInforRows()
    }
    
    func setupDataDetailInforRows() {
        var _orderDetail:Order = Order()
        if orderDetail != nil {
            _orderDetail = orderDetail!
        }
        updateStatusButton?.isHidden = false
        orderInforStatus.removeAll()
        orderInforFrom.removeAll()
        orderInforTo.removeAll()
        orderInforNatureOfGoods.removeAll()
        
        let displayDateTimeVN = DateFormatter.displayDateTimeVN
        let startDate = DateFormatter.serverDateFormater.date(from: _orderDetail.startTime)
        let endDate = DateFormatter.serverDateFormater.date(from: _orderDetail.endTime)
        let status = StatusOrder(rawValue: _orderDetail.statusCode) ?? StatusOrder.newStatus
        let statusItem = OrderDetailInforRow("Status".localized,status.statusName)
        let urgency = OrderDetailInforRow("Urgency".localized ,isHebewLang() ? _orderDetail.urgent_type_name_hb :  _orderDetail.urgent_type_name_en)
        orderInforStatus.append(statusItem)
        //orderInforStatus.append(urgency)
        
        if  _orderDetail.statusOrder == .cancelStatus {
            let reason = OrderDetailInforRow("Failure cause".localized,_orderDetail.reason?.name ?? "-")
            let mess = OrderDetailInforRow("Message".localized,_orderDetail.reason_msg ?? "-")
            orderInforStatus.append(reason)
            orderInforStatus.append(mess)
        }
        
        let fromAddress = OrderDetailInforRow("From address".localized, E(_orderDetail.from?.address),true)
        let fromContactName = OrderDetailInforRow("Contact name".localized,_orderDetail.from?.name ?? "-")
        let fromContactPhone = OrderDetailInforRow("Contact phone".localized,_orderDetail.from?.phone ?? "-",true)
        let toAddress = OrderDetailInforRow("To address".localized, E(_orderDetail.to?.address),true)
        let toContactName = OrderDetailInforRow("Contact name".localized,_orderDetail.to?.name ?? "-")
        let toContactPhone = OrderDetailInforRow("Contact phone".localized,_orderDetail.to?.phone ?? "-", true)
        
        orderInforFrom.append(fromAddress)
        orderInforFrom.append(fromContactName)
        orderInforFrom.append(fromContactPhone)
        
        orderInforTo.append(toAddress)
        orderInforTo.append(toContactName)
        orderInforTo.append(toContactPhone)
    }
  
  
    // MARK: ACTION
    @IBAction func didClickFinish(_ sender: UIButton) {
        handleFinishAction()
    }
  
    @IBAction func didClickUnableToStart(_ sender: UIButton) {
        handleUnableToStartAction()
    }
  
    @IBAction func tapUpdateStatusButtonAction(_ sender: UIButton) {
        self.handleFinishAction()
    }
    
    func handleUnableToStartAction() {
        let vc:ReasonListViewController = .loadSB(SB: .Common)
        vc.orderDetail = orderDetail
        vc.displayMode = .displayModeOrder
        vc.didCancelSuccess =  { [weak self] (success, order) in
            self?.orderDetail = order as? Order
            self?.updateUI()
            self?.setupDataDetailInforRows()
            self?.tableView?.reloadData()
            self?.didUpdateStatus?((self?.orderDetail)!, nil)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleFinishAction() {
        guard let _orderDetail = orderDetail else {return}
        let status:StatusOrder = _orderDetail.statusOrder
        var statusNeedUpdate = status.rawValue
        switch status{
            case .newStatus:
                statusNeedUpdate = StatusOrder.inProcessStatus.rawValue
                updateOrderStatus(statusNeedUpdate)

            case .inProcessStatus:
                statusNeedUpdate = StatusOrder.deliveryStatus.rawValue
                self.updateOrderStatus(statusNeedUpdate)
            
                /*
                if _orderDetail.isRequireImage() &&
                    _orderDetail.url?.doc?.count ?? 0 <= 0{
                    self.showAlertView("Please add pictures in picture tap, before finish this order".localized) {[weak self] (action) in
                        
                        self?.didUpdateStatus?(_orderDetail, 2)
                    }
                    
                }else if (_orderDetail.isRequireSign() &&
                          _orderDetail.url?.sig == nil) {
                    self.showAlertView("Please add signature in signature tap, before finish this order".localized) {[weak self] (action) in
                        
                        self?.didUpdateStatus?(_orderDetail, 1)
                    }
                    
                }else {
                    statusNeedUpdate = StatusOrder.deliveryStatus.rawValue
                    showInputNote(statusNeedUpdate)
                }
                */
            default:
                break
         }
    }
    
    func showInputNote(_ statusNeedUpdate:String) {
        let alert = UIAlertController(style: .alert, title: "Finish order".localized)
        alert.showTextViewInput(placeholder: "Enter note for this order(optional)".localized,
                                nameAction: "Finish".localized,
                                oldText: "") {[weak self] (success, string) in
              self?.orderDetail?.note = string
              self?.updateOrderStatus(statusNeedUpdate)
        }
    }
}


// MARK: - UITableView
extension OrderDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (orderDetail != nil) ? arrTitleHeader.count : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let orderSection:OrderDetailSection = OrderDetailSection(rawValue: section) else {
            return 0
        }
        switch orderSection {
        case .sectionOrderStatus:
            return orderInforStatus.count
        case .sectionFrom:
            return orderInforFrom.count
        case .sectionTo:
            return orderInforTo.count
        case .sectionNatureOfGoods:
            return orderDetail?.details?.count ?? 0
        case .sectionDescription:
          return 1;
        }
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
   
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as? OrderDetailTableViewCell{
            headerCell.nameLabel?.text = arrTitleHeader[section];

            return headerCell;
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
        let orderSection:OrderDetailSection = OrderDetailSection(rawValue: indexPath.section)!
        switch orderSection {
        case .sectionOrderStatus:
            let item = orderInforStatus[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderDetailTableViewCell {
                cell.orderDetailItem = item
                cell.selectionStyle = .none
                
                if indexPath.row == orderInforStatus.count - 1{
                    cell.vContent?.roundCornersLRB()
                }
                
                return cell
            }
        case .sectionFrom:
            let item = orderInforFrom[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                        for: indexPath) as? OrderDetailTableViewCell {
                cell.orderDetailItem = item
                cell.delegate = self
                cell.selectionStyle = .none
                
                if indexPath.row == orderInforFrom.count - 1{
                    cell.vContent?.roundCornersLRB()
                }
                return cell
            }
        
        case .sectionTo:
            let item = orderInforTo[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderDetailTableViewCell {
              cell.orderDetailItem = item
              cell.selectionStyle = .none

                if indexPath.row == orderInforTo.count - 1{
                    cell.vContent?.roundCornersLRB()
                }
              return cell
            }
            
        case .sectionNatureOfGoods:
            if let cell = tableView.dequeueReusableCell(withIdentifier: orderDetailNatureOfGoodsCell,
                                                        for: indexPath) as? OrderDetailTableViewCell {
                cell.selectionStyle = .none
                
                let detail = orderDetail?.details?[indexPath.row]
                cell.nameLabel?.text = detail?.nature?.name
                cell.contentLabel?.text = "\(detail?.vol ?? 0)"
                
                if indexPath.row == (orderDetail?.details?.count ?? 0 ) - 1{
                    cell.vContent?.roundCornersLRB()
                }
                return cell
            }
            
        case .sectionDescription:
          if let cell = tableView.dequeueReusableCell(withIdentifier: addressCellIdentifier, for: indexPath) as? OrderDetailTableViewCell {
            
            let des = E(orderDetail?.note)
            let description = OrderDetailInforRow("Instructions".localized,des)
            cell.orderDetailItem = description
            cell.selectionStyle = .none
            cell.vContent?.roundCornersLRB()
            
            return cell
          }
      }
   
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let orderSection = OrderDetailSection(rawValue:indexPath.section) else {
            return
        }
        let row = indexPath.row
        switch orderSection {
        case .sectionFrom:
            if row == orderInforFrom.count - 1 {// Phone row
                let item = orderInforFrom[row]
            
                if !isEmpty(item.content){
                    let urlString = "tel://\(item.content)"
                    if let url = URL(string: urlString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                
            }else if (row == 0){ //Address row
                let vc:OrderDetailMapViewController = .loadSB(SB: .Order)
                if let _orderDetail = orderDetail {
                    vc.orderLocation = _orderDetail.locationFrom
                }
                //self.present(vc, animated: true, completion: nil)
                self.navigationController?.pushViewController( vc, animated: true)
            }
            
        case .sectionTo:
            if row == orderInforTo.count - 1 {// Phone row
                let item = orderInforTo[row]
                
                if !isEmpty(item.content){
                    let urlString = "tel://\(item.content)"
                    if let url = URL(string: urlString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                
            }else if (row == 0){ //Address row
                let vc:OrderDetailMapViewController = .loadSB(SB: .Order)
                if let _orderDetail = orderDetail {
                    vc.orderLocation = _orderDetail.locationTo
                }
                //self.present(vc, animated: true, completion: nil)
                self.navigationController?.pushViewController( vc, animated: true)
            }
            
        default:
            break
        }
    }
}

//MARK: - OrderDetailTableViewCellDelegate
extension OrderDetailViewController: OrderDetailTableViewCellDelegate {
    func didSelectedDopdown(_ cell: OrderDetailTableViewCell, _ btn: UIButton) {
        let driver = DriverModel(orderDetail?.driver_id,E(orderDetail?.driver_name),nil)
        PickerTypeListVC.showPickerTypeList(pickerType: .DriverSignlePick,
                                            oldData: [driver]) {[weak self] (success, data) in
            if success{
                if let drivers = data as? [DriverModel]{
                    let requestAssignOrder = RequestAssignOrderModel()
                    requestAssignOrder.date = self?.dateStringFilter
                    requestAssignOrder.driver_id = drivers.first?.driver_id
                    requestAssignOrder.order_ids = ["\(self?.orderDetail?.id ?? 0)"]
                    self?.assignOrderToDriver(requestAssignOrder)
                }
            }
        }
    }
}


//MARK: - Otherfuntion
fileprivate extension OrderDetailViewController{
  
    func scrollToBottom(){
        DispatchQueue.main.async {[weak self] in
          let indexPath = IndexPath(row: 0, section: OrderDetailSection.sectionDescription.rawValue)
          self?.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func updateButtonStatus() {
        updateStatusButton?.backgroundColor = AppColor.mainColor
        btnUnable?.backgroundColor = AppColor.white
        btnUnable?.borderWidth = 1;
        btnUnable?.borderColor = AppColor.mainColor
        btnUnable?.setTitleColor(AppColor.mainColor, for: .normal)
        vAction?.isHidden = true
        let driverId = orderDetail?.driver_id
        if driverId == Caches().user?.userInfo?.id {
            switch orderDetail?.statusCode {
            case "OP":
                vAction?.isHidden = false
                updateStatusButton?.setTitle("Start".localized.uppercased(), for: .normal)
                btnUnable?.setTitle("Unable To Start".localized.uppercased(), for: .normal)
                
            case "IP":
                vAction?.isHidden = false
                updateStatusButton?.setTitle("Finish".localized.uppercased(), for: .normal)
                btnUnable?.setTitle("Unable To Finish".localized.uppercased(), for: .normal)
                
            default:
                break
            }
        }
    }
}

//MARK: API
extension OrderDetailViewController{
    private func getOrderDetail(isFetch:Bool = false) {
         if hasNetworkConnection &&
            ReachabilityManager.isCalling == false {
            guard let _orderID = orderDetail?.id else { return }
             if !isFetch {
                showLoadingIndicator()
             }
             API().getOrderDetail(orderId: "\(_orderID)") {[weak self] (result) in
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
    
    func updateOrderStatus(_ statusCode: String) {
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
        
        if !hasNetworkConnection {
            CoreDataManager.updateOrderDetail(_orderDetail) // Save order detail to local DB
            self.setupDataDetailInforRows()
            self.updateButtonStatus()
            self.tableView?.reloadData()
        }
        
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        API().updateOrderStatus(_orderDetail) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.setupDataDetailInforRows()
                self?.updateButtonStatus()
                self?.tableView?.reloadData()
                self?.didUpdateStatus?(_orderDetail,(statusCode == "IP" &&
                                                    _orderDetail.signature == nil &&
                                                    _orderDetail.isRequireSign()) ? 1 : nil)
                // Save Date Start route
                if statusCode == StatusOrder.inProcessStatus.rawValue &&
                    self?.route?.isFirstStartOrder ?? false {
                    Caches().dateStartRoute = Date.now
                    let totalMinutes = Caches().drivingRule?.data ?? 0
                    LocalNotification.createPushNotificationAfter(totalMinutes * 60,
                                                                  "Reminder".localized,
                                                                  "Your task has been over.".localized,
                                                                  "remider.timeout.drivingrole",  [:])
                }
                
                // Check to remove remider timeout driving role
                if statusCode == StatusOrder.deliveryStatus.rawValue {
                    self?.updateRoute()
                    if (self?.route?.checkFinished() ??  false){
                        LocalNotification.removePendingNotifications([NotificationName.remiderTimeoutDrivingRole])
                    }
                }
                
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
        API().assignOrderToDriver(body: requestAssignOrder) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.updateOrderDetail?(self?.orderDetail)
                self?.showAlertView("Assigned successfull.".localized,
                                    completionHandler: { (ok) in
                    let vc:RouteListVC = .loadSB(SB: .Route)
                    vc.dateStringFilter = E(self?.dateStringFilter)
                    App().mainVC?.rootNV?.setViewControllers([vc], animated: false)
                })
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}
