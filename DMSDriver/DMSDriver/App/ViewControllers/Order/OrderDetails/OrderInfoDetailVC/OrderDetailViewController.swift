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
    fileprivate let orderScanItemCellIdentifier = "OrderScanItemTableViewCell"
    fileprivate let orderDropdownCellIdentifier = "OrderDetailDropdownCell"
    fileprivate let orderDetailNatureOfGoodsCell = "OrderDetailNatureOfGoodsCell"
    fileprivate var scanItems = [String]()
    fileprivate var arrTitleHeader:[String] = []
    
    
    fileprivate var scannedString = "" {
        didSet {
            tableView?.reloadData()
        }
    }
  
    var dateStringFilter = Date().toString()
  
    override var orderDetail: OrderDetail? {
        didSet {
            setupDataDetailInforRows()
            updateButtonStatus()
            tableView?.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        initVar()
    }
    
    
    override func reachabilityChangedNotification(_ notification: NSNotification) {
        super.reachabilityChangedNotification(notification)
        checkConnetionInternet?(notification, hasNetworkConnection)
    }
    
    func setupDataDetailInforRows() {
        var _orderDetail:OrderDetail = OrderDetail()
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
        let statusItem = OrderDetailInforRow("Status",status.statusName)
        let urgency = OrderDetailInforRow("Urgency" ,isHebewLang() ? _orderDetail.urgent_type_name_hb :  _orderDetail.urgent_type_name_en)
        orderInforStatus.append(statusItem)
        orderInforStatus.append(urgency)

        if  _orderDetail.status == .cancelStatus {
            let reason = OrderDetailInforRow("Failure cause",_orderDetail.reason?.name ?? "-")
            let mess = OrderDetailInforRow("Message",_orderDetail.reason_msg ?? "-")
            orderInforStatus.append(reason)
            orderInforStatus.append(mess)
        }
        
        let fromAddress = OrderDetailInforRow("From address", E(_orderDetail.from?.address))
        let fromContactName = OrderDetailInforRow("Contact name",_orderDetail.from?.name ?? "-")
        let fromContactPhone = OrderDetailInforRow("Contact phone",_orderDetail.from?.phone ?? "-")

        let toAddress = OrderDetailInforRow("To address", E(_orderDetail.to?.address))
        let toContactName = OrderDetailInforRow("Contact name",_orderDetail.to?.name ?? "-")
        let toContactPhone = OrderDetailInforRow("Contact phone",_orderDetail.to?.phone ?? "-")

        orderInforFrom.append(fromAddress)
        orderInforFrom.append(fromContactName)
        orderInforFrom.append(fromContactPhone)
        
        orderInforTo.append(toAddress)
        orderInforTo.append(toContactName)
        orderInforTo.append(toContactPhone)
    }
    
    override func updateUI()  {
        super.updateUI()
        DispatchQueue.main.async {[weak self] in
            self?.vAction?.isHidden = (self?.orderDetail == nil)
            self?.updateButtonStatus()
            self?.setupTableView()
        }
    }
    
    func setupTableView() {
        let orderScanItemNib = UINib(nibName: orderScanItemCellIdentifier, bundle: nil)
        tableView?.register(orderScanItemNib, forCellReuseIdentifier: orderScanItemCellIdentifier)
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableViewAutomaticDimension
    }
    
    func initVar()  {
        arrTitleHeader = ["ORDER STATUS".localized,
                          "FROM".localized,
                          "TO".localized,
                          "NATURE OF GOODS".localized,
                          "INSTRUCTIONS".localized]
        
        setupDataDetailInforRows()
    }
  
    override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Detail".localized)
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
        if let routeID = route?.id {
            vc.routeID = routeID
        }
        vc.displayMode = .displayModeOrder
        vc.didCancelSuccess =  { [weak self] (success, order) in
            self?.orderDetail = order as? OrderDetail
            self?.didUpdateStatus?((self?.orderDetail)!, nil)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleFinishAction() {
        guard let _orderDetail = orderDetail else {return}
        let status:StatusOrder = _orderDetail.status
        var statusNeedUpdate = status.rawValue
        switch status{
            case .newStatus:
                statusNeedUpdate = StatusOrder.inProcessStatus.rawValue
                updateOrderStatus(statusNeedUpdate)

            case .inProcessStatus:
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


// MARK: - Private methods
extension OrderDetailViewController {
  func updateOrderStatus(_ status: String) {
    guard let _orderDetail = orderDetail,
          let _routeID = route?.id else { return }
    _orderDetail.route_id = _routeID;
    _orderDetail.statusCode = status
    
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
            self?.didUpdateStatus?(_orderDetail,(status == "DV" && _orderDetail.url?.sig == nil) ? 1 : nil)
            //Save Date Start route
            if status == "IP" &&
                self?.route?.isFirstStartOrder ?? false{
                Caches().dateStartRoute = Date.now
            }
            
        case .error(let error):
            self?.showAlertView(error.getMessage())
        }
    }
  }
}

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
            let description = OrderDetailInforRow("Instructions",des)
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
                    vc.orderLocation = _orderDetail.location
                }
                //self.present(vc, animated: true, completion: nil)
                self.navigationController?.pushViewController( vc, animated: true)
            }
            
        default:
            break
        }
    }
}

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
        btnUnable?.backgroundColor = AppColor.grayColor
        btnUnable?.borderWidth = 1;
        btnUnable?.borderColor = AppColor.grayBorderColor
        vAction?.isHidden = true
        var driverId = orderDetail?.route_detail?.driverId
        if driverId == nil{
            driverId = orderDetail?.driver_id // get from local DB
        }

        if driverId == Caches().user?.userInfo?.id {
            switch orderDetail?.statusCode {
            case "OP":
                vAction?.isHidden = false
                updateStatusButton?.setTitle("Start".localized, for: .normal)
                btnUnable?.setTitle("Unable To Start".localized, for: .normal)
                
            case "IP":
                vAction?.isHidden = false
                updateStatusButton?.setTitle("Finish".localized, for: .normal)
                btnUnable?.setTitle("Unable To Finish".localized, for: .normal)
                
            default:
                break
            }
        }
    }
}

//MARK: API
extension OrderDetailViewController{
    
    func assignOrderToDriver(_ requestAssignOrder:RequestAssignOrderModel)  {
        self.showLoadingIndicator()
        API().assignOrderToDriver(body: requestAssignOrder) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.updateOrderDetail?()
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
