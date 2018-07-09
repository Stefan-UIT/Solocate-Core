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
    case sectionOrderInfor = 0;
    case sectionInformation = 1;
    case sectionDescription = 2;
  
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

  fileprivate var orderInforRows = [OrderDetailInforRow]()
  fileprivate var informationRows = [OrderDetailInforRow]()

  fileprivate let cellHeight: CGFloat = 70.0
  fileprivate let orderItemsPaddingTop: CGFloat = 40.0
  fileprivate let orderItemCellHeight: CGFloat = 130.0
  fileprivate let cellIdentifier = "OrderDetailTableViewCell"
  fileprivate let headerCellIdentifier = "OrderDetailHeaderCell"
  fileprivate let addressCellIdentifier =  "OrderDetailAddressCell"
  fileprivate let orderScanItemCellIdentifier = "OrderScanItemTableViewCell"
  fileprivate var scanItems = [String]()
  fileprivate let itemsIndex = 8
  fileprivate var scannedObjectIndexs = [Int]()
  fileprivate var shouldFilterOrderItemsList = true
  fileprivate var scannedString = "" {
    didSet {
      tableView.reloadData()
    }
  }
  
  
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
        orderInforRows.removeAll()
        informationRows.removeAll()
        let orderId = OrderDetailInforRow(.orderId,"\(_orderDetail.id)")
        
        let status = OrderStatus(rawValue: _orderDetail.statusCode) ?? OrderStatus.open
        let statusItem = OrderDetailInforRow(.status,status.statusName)
        
        let type = OrderDetailInforRow(.type, _orderDetail.orderType)
        let ref = OrderDetailInforRow(.reference , _orderDetail.orderReference)
        
        let startTime = OrderDetailInforRow(.startTime, _orderDetail.startTime)
        let endTime = OrderDetailInforRow(.endTime , _orderDetail.endTime)
        let serviceTime = OrderDetailInforRow(.serviceTime ,"\(_orderDetail.serviceTime)")
        let seq = OrderDetailInforRow(.seq ,"\(_orderDetail.seq)")
        let pallets = OrderDetailInforRow(.pallets ,"\(_orderDetail.pallets)")
        let cases = OrderDetailInforRow(.cases ,"\(_orderDetail.cases)")
        
        let dateTime = _orderDetail.timeWindowName.length > 0 ? _orderDetail.deliveryDate + " - " + _orderDetail.timeWindowName : _orderDetail.deliveryDate
        let delDate = OrderDetailInforRow(.deliveryDate,dateTime )
        
        let customer = OrderDetailInforRow(.customerName,_orderDetail.deliveryContactName)
        let phone = OrderDetailInforRow(.phone,_orderDetail.deliveryContactPhone)
        
        let address = OrderDetailInforRow(.address,_orderDetail.deliveryAdd + "\n\(_orderDetail.deliveryCity)")
        
        shouldFilterOrderItemsList = _orderDetail.items.filter({$0.statusCode == "OP"}).count > 0
        
        orderInforRows.append(orderId)
        orderInforRows.append(statusItem)
        orderInforRows.append(type)
        orderInforRows.append(ref)
        orderInforRows.append(startTime)
        orderInforRows.append(endTime)
        orderInforRows.append(serviceTime)
        orderInforRows.append(seq)
        orderInforRows.append(pallets)
        orderInforRows.append(cases)
        orderInforRows.append(delDate)
      
        informationRows.append(customer)
        informationRows.append(phone)
        informationRows.append(address)
      
        updateStatusButton.isHidden = _orderDetail.statusCode != "OP" && _orderDetail.statusCode != "IP"
    }
  
    var didUpdateStatus:((_ orderDetail:OrderDetail, _ shouldMoveSigatureTab: Bool ) -> Void)?
    var updateOrderDetail:(() -> Void)?
  
    override func viewDidLoad() {
        super.viewDidLoad()

        let orderScanItemNib = UINib(nibName: orderScanItemCellIdentifier, bundle: nil)
        updateStatusButton.isHidden = true
        tableView.register(orderScanItemNib, forCellReuseIdentifier: orderScanItemCellIdentifier)
        tableView.estimatedRowHeight = cellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    
        navigationController?.navigationBar.tintColor = .white
    
        initVar()
        setupDataDetailInforRows()
    }
    
    func initVar()  {
        arrTitleHeader = ["Order Information",
                          "Information",
                          "Description"]
    }
  
    override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "order_detail_title".localized)
    }
    
  
  
  // MARK: ACTION
  @IBAction func didClickFinish(_ sender: UIButton) {
    guard let _orderDetail = orderDetail else {return}
    let status = _orderDetail.statusCode == "OP" ? "IP" : "DV"
    updateOrderStatus(status)
  }
  
  @IBAction func didClickUnableToStart(_ sender: UIButton) {
    handleUnableToStartAction()
  }
  
  @IBAction func tapUpdateStatusButtonAction(_ sender: UIButton) {
    //handleUpdateStatus() //https://seldat.atlassian.net/browse/NNCT-175
    self.handleFinishAction()
  }
    
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == SegueIdentifier.showMapView,
      let vc = segue.destination as? OrderDetailMapViewController,
      let _orderDetail = orderDetail {
      let orderLocation = CLLocationCoordinate2D(latitude: _orderDetail.lat.doubleValue, longitude: _orderDetail.lng.doubleValue)
      vc.orderLocation = orderLocation
    }
    else if segue.identifier == SegueIdentifier.showReasonList,
      let vc = segue.destination as? ReasonListViewController {
      vc.orderDetail = orderDetail
      vc.routeID = routeID
      vc.type = "1"
      if let orderItem = sender as? OrderItem { // for order item
        vc.type = "2"
        vc.itemID = "\(orderItem.id)"
      }
    }
  }
    
    
    // MARK: - Function -
    func handleUpdateStatus() {
        
        guard let _orderDetail = orderDetail else { return }

        let alert = UIAlertController(title: "", message: "Update Status Order", preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
  
        
        let finishActionTitle = _orderDetail.statusCode == "OP" ? "start".localized : "finish".localized

        let finishAction = UIAlertAction(title: finishActionTitle, style: .default) { (alertAction) in
            self.handleFinishAction()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(finishAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleUnableToStartAction() {
      self.showAlertView("Sorry, this feature hasn't developed!")
      //performSegue(withIdentifier: SegueIdentifier.showReasonList, sender: nil)
    }
    
    func handleFinishAction() {
        guard let _orderDetail = orderDetail else {return}
        let status = _orderDetail.statusCode == "OP" ? "IP" : "DV"
        updateOrderStatus(status)
    }
    
    func handleScanMatchBarCode() {
        guard let _orderDetail = orderDetail, _orderDetail.statusCode == "IP" else {return}
        let scanVC = ScanBarCodeViewController.loadViewController(type: ScanBarCodeViewController.self)
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
    guard let order = orderDetail else {
      return
    }
    let message = String.init(format: "order_detail_add_order_item".localized, barcode)
    let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
    alert.addTextField { (textField) in
      textField.placeholder = "order_detail_quality".localized
      textField.keyboardType = .numberPad
    }
    let okAction = UIAlertAction(title: "submit".localized, style: .default) { [unowned self] (action) in
      guard let textField = alert.textFields?.first,
        textField.hasText,
        let qtyText = textField.text else {
          return
      }
      self.showLoadingIndicator()
      APIs.addNewOrderItem("\(order.id)", barcode: barcode, qty: qtyText, completion: { (errMsg) in
        guard let msg = errMsg else {
          self.updateOrderDetail?()
          self.scannedString = ""
          self.scannedObjectIndexs.removeAll()
          return
        }
        self.showAlertView(msg)
      })
    }
    let cancel = UIAlertAction(title: "cancel".localized, style: .default, handler: nil)
    alert.addAction(cancel)
    alert.addAction(okAction)
    present(alert, animated: true, completion: nil)
  }
  
  func showAlertUpdateBarcode(_ barcode: String, item: OrderItem) {
    let message = String.init(format: "order_detail_update_barcode".localized, barcode)
    let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "submit".localized, style: .default) { [unowned self] (action) in
      self.showLoadingIndicator()
      APIs.updateBarcode("\(item.id)", newBarcode: barcode, completion: { (errMsg) in
        self.dismissLoadingIndicator()
        guard let msg = errMsg else {
          self.scannedString = ""
          self.scannedObjectIndexs.removeAll()
          self.updateOrderDetail?()
          return
        }
        self.showAlertView(msg)
      })
    }
    let cancel = UIAlertAction(title: "cancel".localized, style: .default, handler: nil)
    alert.addAction(cancel)
    alert.addAction(okAction)
    present(alert, animated: true, completion: nil)
  }
  
  func updateItemStatus(_ status: String, orderItem: OrderItem) {
    APIs.updateOrderItemStatus("\(orderItem.id)", status: status, reason: nil) { [unowned self] (errMsg) in
      if let msg = errMsg {
        self.showAlertView(msg)
      }
      else {
        self.updateOrderDetail?()
      }
    }
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
      let scanVC = ScanBarCodeViewController.loadViewController(type: ScanBarCodeViewController.self)
      scanVC.didScan = {
        [unowned self] (code) in
        if code.length > 0 {
          self.showAlertUpdateBarcode(code, item: item)
        }
      }
      self.present(scanVC, animated: true, completion: nil)
      
    }
    let finish = UIAlertAction(title: "finish".localized, style: .default) { [unowned self] (finihs) in
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
            self?.didUpdateStatus?(_orderDetail, (status == "DV"))

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
        return 55
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
    view.backgroundColor = AppColor.grayColor
    return view
  }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let orderSection:OrderDetailSection = OrderDetailSection(rawValue: indexPath.section)!
        switch orderSection {
        case .sectionOrderInfor:
            let item = orderInforRows[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                        for: indexPath) as? OrderDetailTableViewCell {
                cell.orderDetailItem = item
                cell.selectionStyle = !(item.type == .phone && item.type == .address) ? .none : .default
                return cell
            }
        
        case .sectionInformation:
            let item = informationRows[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderDetailTableViewCell {
              cell.orderDetailItem = item

              return cell
            }
        case .sectionDescription:
          if let cell = tableView.dequeueReusableCell(withIdentifier: addressCellIdentifier, for: indexPath) as? OrderDetailTableViewCell {
            
            let des = E(orderDetail?.descriptionNote) + " " + E(orderDetail?.descriptionNoteExt)
            let description = OrderDetailInforRow(.description,des)
            cell.orderDetailItem = description
            
            return cell
          }
      }
   
    return UITableViewCell()
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
            updateStatusButton.setTitle("Start", for: .normal)
            btnUnable.setTitle("Unable To Start", for: .normal)

        case "IP":
            updateStatusButton.setTitle("Finish", for: .normal)
            btnUnable.setTitle("Unable To Finish", for: .normal)

        default:
            updateStatusButton.isHidden = true
            btnUnable.isHidden = true
        }
    }
    
}
