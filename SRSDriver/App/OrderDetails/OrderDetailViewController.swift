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

class OrderDetailViewController: BaseOrderDetailViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var updateStatusButton: UIButton!
    
  var subTableView: UITableView!
  
  fileprivate var detailItems = [OrderDetailItem]()
  fileprivate let cellHeight: CGFloat = 70.0
  fileprivate let orderItemsPaddingTop: CGFloat = 40.0
  fileprivate let orderItemCellHeight: CGFloat = 130.0
  fileprivate let cellIdentifier = "OrderDetailTableViewCell"
  fileprivate let orderItemsCellIdentifier = "OrderItemsTableViewCell"
  fileprivate let orderScanItemCellIdentifier = "OrderScanItemTableViewCell"
  fileprivate var scanItems = [String]()
  fileprivate let itemsIndex = 8
  fileprivate var scannedObjectIndexs = [Int]()
  fileprivate var shouldFilterOrderItemsList = true
  fileprivate var scannedString = "" {
    didSet {
      tableView.reloadData()
      subTableView.reloadData()
    }
  }
  
  
  override var orderDetail: OrderDetail? {
    didSet {      
      guard let _orderDetail = orderDetail else { return }
      updateStatusButton.isHidden = false
      detailItems.removeAll()
      var refe = OrderDetailItem(.reference)
      refe.content = _orderDetail.orderReference
      var statusItem = OrderDetailItem(.status)
      let status = OrderStatus(rawValue: _orderDetail.statusCode)!
      statusItem.content = status.statusName
      var type = OrderDetailItem(.type)
      type.content = _orderDetail.orderType
      var delDate = OrderDetailItem(.deliveryDate)
      let dateTime = _orderDetail.timeWindowName.length > 0 ? _orderDetail.deliveryDate + " - " + _orderDetail.timeWindowName : _orderDetail.deliveryDate
      delDate.content = dateTime
      var customer = OrderDetailItem(.customerName)
      customer.content = _orderDetail.deliveryContactName
      var phone = OrderDetailItem(.phone)
      phone.content = _orderDetail.deliveryContactPhone
      var address = OrderDetailItem(.address)
        address.content = _orderDetail.deliveryAdd + "\n\(_orderDetail.deliveryCity)"
      var description = OrderDetailItem(.description)
      description.content = _orderDetail.descriptionNote + " " + _orderDetail.descriptionNoteExt
      var items = OrderDetailItem(.items)
      items.content = ""
      items.items = _orderDetail.items
      shouldFilterOrderItemsList = _orderDetail.items.filter({$0.statusCode == "OP"}).count > 0
      
      
      detailItems.append(refe)
      detailItems.append(statusItem)
      detailItems.append(type)
      detailItems.append(delDate)
      detailItems.append(customer)
      detailItems.append(phone)
      detailItems.append(address)
      detailItems.append(description)
      detailItems.append(items)
      
      tableView.reloadData()
      subTableView.reloadData()
      
      updateStatusButton.isHidden = _orderDetail.statusCode != "OP" && _orderDetail.statusCode != "IP"
    }
  }
  
  var didUpdateStatus:((_ shouldMoveSigatureTab: Bool ) -> Void)?
  var updateOrderDetail:(() -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    subTableView = UITableView(frame: CGRect.zero, style: .plain)
    subTableView.delegate = self
    subTableView.dataSource = self
    let orderScanItemNib = UINib(nibName: orderScanItemCellIdentifier, bundle: nil)
    subTableView.register(orderScanItemNib, forCellReuseIdentifier: orderScanItemCellIdentifier)
    subTableView.isScrollEnabled = false
    updateStatusButton.isHidden = true
    
    tableView.estimatedRowHeight = cellHeight
    tableView.rowHeight = UITableViewAutomaticDimension
    
    navigationController?.navigationBar.tintColor = .white
  }
  
  override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: "order_detail_title".localized)
  }
  
  @IBAction func didClickFinish(_ sender: UIButton) {
    guard let _orderDetail = orderDetail else {return}
    let status = _orderDetail.statusCode == "OP" ? "IP" : "DV"
    updateOrderStatus(status)
  }
  
  @IBAction func didClickUnableToStart(_ sender: UIButton) {
    performSegue(withIdentifier: SegueIdentifier.showReasonList, sender: nil)
  }
  
    @IBAction func tapUpdateStatusButtonAction(_ sender: UIButton) {
        handleUpdateStatus()
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

        let unableTitle = _orderDetail.statusCode == "OP" ? "order_detail_unable_start".localized : "order_detail_unable_finish".localized

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let unableToStartAction = UIAlertAction(title: unableTitle, style: .destructive) { (alertAction) in
            self.handleUnableToStartAction()
        }
        
        let finishActionTitle = _orderDetail.statusCode == "OP" ? "start".localized : "finish".localized

        let finishAction = UIAlertAction(title: finishActionTitle, style: .default) { (alertAction) in
            self.handleFinishAction()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(finishAction)
        alert.addAction(unableToStartAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleUnableToStartAction() {
        performSegue(withIdentifier: SegueIdentifier.showReasonList, sender: nil)
    }
    
    func handleFinishAction() {
        guard let _orderDetail = orderDetail else {return}
        let status = _orderDetail.statusCode == "OP" ? "IP" : "DV"
        updateOrderStatus(status)
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
    showLoadingIndicator()
    APIs.updateOrderStatus("\(_orderDetail.id)", expectedStatus: status, routeID: "\(_routeID)") { [unowned self] (errMsg) in
      self.dismissLoadingIndicator()
      if let err = errMsg {
        self.showAlertView(err)
      }
      else {
        let shouldMoveSignatureTab = status == "DV" // Expected Status DV
        self.didUpdateStatus?(shouldMoveSignatureTab)
      }
    }
  }
}

extension OrderDetailViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard itemsIndex < detailItems.count else {return 0}
    let item = detailItems[itemsIndex]
    if tableView == subTableView {
      return item.items.count
    }
    return detailItems.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard indexPath.row < detailItems.count else {return UITableViewAutomaticDimension}
    let item = detailItems[indexPath.row]
    if tableView == subTableView {
      return orderItemCellHeight.scaleHeight()
    }
    if item.type == .items {
      return item.items.count > 0 ? CGFloat(item.items.count) * orderItemCellHeight.scaleHeight() + orderItemsPaddingTop : orderItemsPaddingTop.scaleHeight() + cellHeight
    }
    return UITableViewAutomaticDimension
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if tableView == subTableView,
      let cell = subTableView.dequeueReusableCell(withIdentifier: orderScanItemCellIdentifier, for: indexPath) as? OrderScanItemTableViewCell {
      let orderItem = detailItems[itemsIndex]
      cell.orderItem = orderItem.items[indexPath.row]
      if scannedString.length > 0, scannedObjectIndexs.contains(indexPath.row), shouldFilterOrderItemsList {
        cell.contentView.backgroundColor = AppColor.highLightColor
      }
      else {
        cell.contentView.backgroundColor = .white
      }
      return cell
    }
    else if tableView == self.tableView {
      let item = detailItems[indexPath.row]
      if item.type == .items,
        let cell = tableView.dequeueReusableCell(withIdentifier: orderItemsCellIdentifier, for: indexPath) as? OrderItemsTableViewCell {
        subTableView.frame = CGRect(x: 0, y: orderItemsPaddingTop, width: cell.frame.width, height: CGFloat(item.items.count)*orderItemCellHeight.scaleHeight())
        cell.contentView.addSubview(subTableView)
        cell.selectionStyle = .none
        cell.didClickScanButton = { [weak self] () in
          guard let strongSelf = self else {return}
          guard let _orderDetail = strongSelf.orderDetail, _orderDetail.statusCode == "IP" else {return}
          let scanVC = ScanBarCodeViewController.loadViewController(type: ScanBarCodeViewController.self)
          scanVC.didScan = {
            [weak self] (code) in
            guard let strongSelf = self else {return}
            let orderItem = strongSelf.detailItems[strongSelf.itemsIndex]
            guard code.length > 0 else {return}
            
            if strongSelf.shouldFilterOrderItemsList {
              strongSelf.scannedObjectIndexs = strongSelf.findIndexOfScannedObject(code, items: orderItem.items)
              if strongSelf.scannedObjectIndexs.count == 0 {
                strongSelf.showAlertView("order_detail_barcode_notmatch".localized)
              }
            }
            else {
              strongSelf.showAlertAddNewOrderItem(code)
            }
            strongSelf.scannedString = code
            
          }
          strongSelf.scannedString = ""
          strongSelf.present(scanVC, animated: true, completion: nil)
        }
        return cell
      } // end if order item cell
      else if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderDetailTableViewCell {
        cell.orderDetailItem = item
        cell.selectionStyle = !(item.type == .phone && item.type == .address) ? .none : .default
        return cell
      } // detail item cell
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if tableView == subTableView {
      let orderItem = detailItems[itemsIndex]
      showActionForOrderItem(orderItem.items[indexPath.row])
      return
    }
    let item = detailItems[indexPath.row]
    if item.type == .address {
      performSegue(withIdentifier: SegueIdentifier.showMapView, sender: nil)
    }
    else if item.type == .phone {
      let urlString = "tel://\(item.content)"
      if let url = URL(string: urlString) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    }
  }
  
}
