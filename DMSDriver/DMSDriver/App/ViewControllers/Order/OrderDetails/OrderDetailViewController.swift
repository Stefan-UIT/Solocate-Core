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
    case sectionOrderInfor
    case sectionInformation
    case sectionDescription
  
    static let count: Int = {
      var max: Int = 0
      while let _ = OrderDetailSection(rawValue: max) { max += 1 }
      return max
    }()
}


class OrderDetailViewController: BaseOrderDetailViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var updateStatusButton: UIButton!
  @IBOutlet weak var btnUnable: UIButton!

    
  var subTableView: UITableView!
  
  fileprivate var arrTitleHeader:[String] = []

  fileprivate var orderInforStatus = [OrderDetailInforRow]()
  fileprivate var orderInforRows = [OrderDetailInforRow]()
  fileprivate var informationRows = [OrderDetailInforRow]()

  fileprivate let cellHeight: CGFloat = 70.0
  fileprivate let orderItemsPaddingTop: CGFloat = 40.0
  fileprivate let orderItemCellHeight: CGFloat = 130.0
  fileprivate let cellIdentifier = "OrderDetailTableViewCell"
  fileprivate let headerCellIdentifier = "OrderDetailHeaderCell"
  fileprivate let addressCellIdentifier =  "OrderDetailAddressCell"
  fileprivate let orderScanItemCellIdentifier = "OrderScanItemTableViewCell"
  fileprivate let orderDropdownCellIdentifier = "OrderDetailDropdownCell"
  fileprivate var scanItems = [String]()
  fileprivate let itemsIndex = 8
  fileprivate var scannedObjectIndexs = [Int]()
  fileprivate var shouldFilterOrderItemsList = true
  fileprivate var scannedString = "" {
    didSet {
      tableView.reloadData()
    }
  }
  
    var dateStringFilter = Date().toString()
  
    override var orderDetail: OrderDetail? {
        didSet {
            setupDataDetailInforRows()
            updateButtonStatus()
            tableView.reloadData()
        }
    }
    
    func setupDataDetailInforRows() {
        var _orderDetail:OrderDetail = OrderDetail()
        if orderDetail != nil {
            _orderDetail = orderDetail!
        }
        updateStatusButton.isHidden = false
        orderInforStatus.removeAll()
        orderInforRows.removeAll()
        informationRows.removeAll()
        
        let status = OrderStatus(rawValue: _orderDetail.statusCode) ?? OrderStatus.open
        let statusItem = OrderDetailInforRow(.status,
                                             status.statusName)
        let urgency = OrderDetailInforRow(.urgency ,isHebewLang() ? _orderDetail.urgent_type_name_hb :  _orderDetail.urgent_type_name_en)
        orderInforStatus.append(statusItem)
        orderInforStatus.append(urgency)

        if  _orderDetail.status == .cancelStatus {
            let reason = OrderDetailInforRow(.failureCause,
                                             E(_orderDetail.reason?.name))
            let mess = OrderDetailInforRow(.message,
                                           E(_orderDetail.reason_msg))
            orderInforStatus.append(reason)
            orderInforStatus.append(mess)
        }
        
        let driver = OrderDetailInforRow(.driver,"\(_orderDetail.driver_name)")
        let orderId = OrderDetailInforRow(.orderId,"\(_orderDetail.id)")
        let startTime = OrderDetailInforRow(.startTime, "\(_orderDetail.endTime)")
        let endTime = OrderDetailInforRow(.endTime, "\(_orderDetail.endTime)")

        let date = OrderDetailInforRow(.date,_orderDetail.deliveryDate)
        let clientName = OrderDetailInforRow(.clientName,_orderDetail.client_name)
        let customerName = OrderDetailInforRow(.customerName ,
                                               _orderDetail.custumer_name)
        let type = OrderDetailInforRow(.type , isHebewLang() ? _orderDetail.order_type_name_hb : _orderDetail.order_type_name)
        let doubleType = OrderDetailInforRow(.doubleType,
                                             "\(_orderDetail.doubleType)")
        let packetNumber = OrderDetailInforRow(.packagesNumber ,
                                               _orderDetail.orderReference)
        let packetNumber2 = OrderDetailInforRow(.packagesNumber ,
                                               "\(_orderDetail.packages)")

        let cartonsNumber = OrderDetailInforRow(.cartonsNumber,
                                                "\(_orderDetail.cartons)")
        let seq = OrderDetailInforRow(.SEQ,
                                                 "\(_orderDetail.seq)")

        let vehical = OrderDetailInforRow(.vehicle, _orderDetail.truck_name)
        let collectCall = OrderDetailInforRow(.collectCall,
                                              _orderDetail.collectionCall)
        let coordinationPhone = OrderDetailInforRow(.coordinationPhone,
                                          _orderDetail.coordinationPhone)
        let executionTime = OrderDetailInforRow(.executionTime, "\(_orderDetail.standby)")
        let receiverName = OrderDetailInforRow(.receiverName,
                                               _orderDetail.receiveName)
        
        var fullAddress = ""
        if let orderType = OrderType(rawValue: _orderDetail.orderTypeId){
            switch orderType{
            case .delivery:
                fullAddress = E(_orderDetail.toAddressFullAddress)
            case .pickup:
                fullAddress = E(_orderDetail.from_address_full_addr)
            case .deliveryAndPickup:
                break
            }
        }
     
        let address = OrderDetailInforRow(.address,fullAddress)
        let phone = OrderDetailInforRow(.phone,
                                        _orderDetail.receiverPhone)
        
        let thirdCourier = OrderDetailInforRow(.thirdCourier,
                                        _orderDetail.thirdCourier)
        
        shouldFilterOrderItemsList = _orderDetail.items.filter({$0.statusCode == "OP"}).count > 0
        
        if (Caches().user?.isAdmin ?? false ||
            Caches().user?.isCoordinator ?? false) &&
            _orderDetail.status == StatusOrder.newStatus {
            orderInforRows.append(driver)
        }
        orderInforRows.append(orderId)
        orderInforRows.append(type)
        orderInforRows.append(packetNumber)
        orderInforRows.append(startTime)
        orderInforRows.append(endTime)
        orderInforRows.append(executionTime)
        orderInforRows.append(doubleType)
        orderInforRows.append(packetNumber2)
        orderInforRows.append(cartonsNumber)
        orderInforRows.append(vehical)
        orderInforRows.append(seq)
        orderInforRows.append(date)
        
        informationRows.append(clientName)
        informationRows.append(thirdCourier)
        informationRows.append(customerName)
        informationRows.append(receiverName)
        informationRows.append(phone)
        informationRows.append(collectCall)
        informationRows.append(coordinationPhone)
        informationRows.append(address)
      
        updateStatusButton.isHidden = _orderDetail.status != .newStatus &&
                                      _orderDetail.status != .inProcessStatus
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        initVar()
        setupDataDetailInforRows()
    }
    
    func updateUI()  {
        updateStatusButton.isHidden = true
        setupTableView()
    }
    
    func setupTableView() {
        let orderScanItemNib = UINib(nibName: orderScanItemCellIdentifier, bundle: nil)
        tableView.register(orderScanItemNib, forCellReuseIdentifier: orderScanItemCellIdentifier)
        tableView.estimatedRowHeight = cellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func initVar()  {
        arrTitleHeader = ["Order Status".localized,
                          "Order Information".localized,
                          "Information".localized,
                          "Instructions".localized]
        
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
        let vc:ReasonListViewController = .loadSB(SB: .Order)
        vc.orderDetail = orderDetail
        vc.routeID = routeID
        vc.type = "1"
        vc.didCancelSuccess =  { [weak self] (success, order) in
            self?.didUpdateStatus?(order, nil)
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
                    _orderDetail.url?.doc == nil{
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
                    updateOrderStatus(statusNeedUpdate)
                }
                
            default:
                break
         }
    }
    
    
    func handleScanMatchBarCode() {
        guard let _orderDetail = orderDetail, _orderDetail.statusCode == "IP" else {return}
        let scanVC:ScanBarCodeViewController = .loadSB(SB: .Order)
        scanVC.didScan = { [weak self] (code) in
            self?.handleDidScanMatchBarCode(code)
        }
        scannedString = ""
        present(scanVC, animated: true, completion: nil)

    }
    
    func handleDidScanMatchBarCode(_ code: String) {
        let orderItem = orderDetail?.items
        
        guard code.length > 0 else { return }
        
        if shouldFilterOrderItemsList {
            scannedObjectIndexs = findIndexOfScannedObject(code, items: orderItem!)
            if scannedObjectIndexs.count == 0 {
                showAlertView("order_detail_barcode_notmatch".localized)
            }
        } else {
            showAlertAddNewOrderItem(code)
        }
        scannedString = code
    }
}

// MARK: - Private methods

extension OrderDetailViewController {
  
  func showAlertAddNewOrderItem(_ barcode: String) {
    //
  }
  
  func showAlertUpdateBarcode(_ barcode: String, item: OrderItem) {
    //
  }
  
  func updateItemStatus(_ status: String, orderItem: OrderItem) {
   
  }
  
  func findObject(_ code: String, items: [OrderItem]) -> OrderItem? {
    return items.filter { (item) -> Bool in
      return item.barcode == code
      }.first
  }
  
  func findIndexOfScannedObject(_ code: String, items: [OrderItem]) -> [Int] {
    var indexs = [Int]()
    for (idx, item) in items.enumerated() {
      if item.barcode == code {
        indexs.append(idx)
      }
    }
    return indexs
  }
  
  
  func showActionForOrderItem(_ item: OrderItem) {
    guard let _orderDetail = orderDetail, _orderDetail.statusCode == "IP" else {
        showAlertView("Order is not yet started.")
      return
    }
    guard item.statusCode != "DV" && item.statusCode != "CC" else {
      return
    }
    let actionSheet = UIAlertController(title: "app_name".localized, message: nil, preferredStyle: .actionSheet)
    let cancel = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
    let reject = UIAlertAction(title: "reject".localized, style: .default) { [unowned self] (reject) in
      self.performSegue(withIdentifier: SegueIdentifier.showReasonList, sender: item)
    }
    let management = UIAlertAction(title: "order_detail_scan_barcode".localized, style: .default) { [unowned self] (management) in
      let scanVC:ScanBarCodeViewController = .loadSB(SB: SBName.Order)
      scanVC.didScan = {
        [unowned self] (code) in
        if code.length > 0 {
          self.showAlertUpdateBarcode(code, item: item)
        }
      }
      self.present(scanVC, animated: true, completion: nil)
      
    }
    let finish = UIAlertAction(title: "Finish".localized, style: .default) { [unowned self] (finihs) in
      self.updateItemStatus("DV", orderItem: item)
    }
    
    actionSheet.addAction(reject)
    actionSheet.addAction(management)
    actionSheet.addAction(finish)
    actionSheet.addAction(cancel)
    present(actionSheet, animated: true, completion: nil)
  }
  
  func updateOrderStatus(_ status: String) {
    guard let _orderDetail = orderDetail,
          let _routeID = routeID else { return }
    _orderDetail.routeId = _routeID;
    _orderDetail.statusCode = status
    
    showLoadingIndicator()
    API().updateOrderStatus(_orderDetail) {[weak self] (result) in
        self?.dismissLoadingIndicator()

        switch result{
        case .object(_):
            self?.setupDataDetailInforRows()
            self?.updateButtonStatus()
            self?.tableView.reloadData()
            self?.didUpdateStatus?(_orderDetail, (status == "DV" && _orderDetail.url?.sig == nil) ? 1 : nil)

        case .error(let error):
            self?.showAlertView(error.getMessage())
        }
    }
  }
}

extension OrderDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrTitleHeader.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let orderSection:OrderDetailSection = OrderDetailSection(rawValue: section)!
        switch orderSection {
        case .sectionOrderStatus:
            return orderInforStatus.count
        case .sectionOrderInfor:
            return orderInforRows.count
        case .sectionInformation:
            return informationRows.count
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
        return 35
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
                return cell
            }
        case .sectionOrderInfor:
            let item = orderInforRows[indexPath.row]
            var identifier = cellIdentifier
            if item.type == .driver {
                identifier = orderDropdownCellIdentifier
            }
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                        for: indexPath) as? OrderDetailTableViewCell {
                cell.orderDetailItem = item
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            }
        
        case .sectionInformation:
            let item = informationRows[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderDetailTableViewCell {
              cell.orderDetailItem = item
              cell.selectionStyle = .none

              return cell
            }
        case .sectionDescription:
          if let cell = tableView.dequeueReusableCell(withIdentifier: addressCellIdentifier, for: indexPath) as? OrderDetailTableViewCell {
            
            let des = E(orderDetail?.instructions)
            let description = OrderDetailInforRow(.comments,des)
            cell.orderDetailItem = description
            cell.selectionStyle = .none

            return cell
          }
      }
   
    return UITableViewCell()
  }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderSection:OrderDetailSection = OrderDetailSection(rawValue: indexPath.section)!
        let row = indexPath.row
        switch orderSection {
        case .sectionInformation:
            if row == 1 {// Phone row
                let item = informationRows[row]
                let urlString = "tel://\(item.content)"
                if let url = URL(string: urlString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                break
                
            }else if (row == informationRows.count - 1){ //Address row
                let vc:OrderDetailMapViewController = .loadSB(SB: .Order)
                if let _orderDetail = orderDetail {
                    let orderLocation = CLLocationCoordinate2D(latitude: _orderDetail.to_address_lattd.doubleValue,
                                                               longitude: _orderDetail.to_address_lngtd.doubleValue)
                    vc.orderLocation = orderLocation
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
    DispatchQueue.main.async {
      let indexPath = IndexPath(row: 0, section: OrderDetailSection.sectionDescription.rawValue)
      self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
  }
    
    func updateButtonStatus() {
        updateStatusButton.backgroundColor = AppColor.mainColor
        btnUnable.backgroundColor = AppColor.grayColor
        btnUnable.borderWidth = 1;
        btnUnable.borderColor = AppColor.grayBorderColor
        updateStatusButton.isHidden = false
        btnUnable.isHidden = false

        switch orderDetail?.statusCode {
        case "OP":
            updateStatusButton.setTitle("Start".localized, for: .normal)
            btnUnable.setTitle("Unable To Start".localized, for: .normal)

        case "IP":
            updateStatusButton.setTitle("Finish".localized, for: .normal)
            btnUnable.setTitle("Unable To Finish".localized, for: .normal)

        default:
            updateStatusButton.isHidden = true
            btnUnable.isHidden = true
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
                self?.showAlertView("Assigned successfull.".localized, completionHandler: { (ok) in
                    App().mainVC?.pushRouteListVC()
                })
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}
