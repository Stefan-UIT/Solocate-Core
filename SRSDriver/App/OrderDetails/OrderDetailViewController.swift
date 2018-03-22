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
  @IBOutlet weak var unableToStartButton: UIButton!
  @IBOutlet weak var finishButton: UIButton!
  @IBOutlet weak var controlsStackView: UIStackView!
  var subTableView: UITableView!
  
  fileprivate var detailItems = [OrderDetailItem]()
  fileprivate let cellHeight: CGFloat = 70.0
  fileprivate let cellIdentifier = "OrderDetailTableViewCell"
  fileprivate let orderItemsCellIdentifier = "OrderItemsTableViewCell"
  fileprivate let orderScanItemCellIdentifier = "OrderScanItemTableViewCell"
  fileprivate var scanItems = [String]()
  fileprivate let itemsIndex = 7
  fileprivate var scannedString = "" {
    didSet {
      tableView.reloadData()
      subTableView.reloadData()
    }
  }
  
  override var orderDetail: OrderDetail? {
    didSet {      
      guard let _orderDetail = orderDetail else { return }
      var refe = OrderDetailItem(.reference)
      refe.content = _orderDetail.orderReference
      var status = OrderDetailItem(.status)
      status.content = _orderDetail.statusCode == "DV" ? "Delivery" : (_orderDetail.statusCode == "IP" ? "In Progress" : "Open")
      var delDate = OrderDetailItem(.deliveryDate)
      delDate.content = _orderDetail.deliveryDate + " - " + _orderDetail.timeWindowName
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
      
      detailItems.append(refe)
      detailItems.append(status)
      detailItems.append(delDate)
      detailItems.append(customer)
      detailItems.append(phone)
      detailItems.append(address)
      detailItems.append(description)
      detailItems.append(items)
      
      tableView.reloadData()
      
      finishButton.isEnabled = _orderDetail.statusCode == "OP" || _orderDetail.statusCode == "IP"
      let finishButtonTitle = _orderDetail.statusCode == "OP" ? "Start" : "Finish"
      finishButton.setTitle(finishButtonTitle, for: .normal)
      
      unableToStartButton.isEnabled = _orderDetail.statusCode == "OP" || _orderDetail.statusCode == "IP"
      let unableTitle = _orderDetail.statusCode == "OP" ? "Unable to Start" : "Unable to Finish"
      unableToStartButton.setTitle(unableTitle, for: .normal)
    }
  }
  
  var didUpdateStatus:(() -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    subTableView = UITableView(frame: CGRect.zero, style: .plain)
    subTableView.delegate = self
    subTableView.dataSource = self
    let orderScanItemNib = UINib(nibName: "OrderScanItemTableViewCell", bundle: nil)
    subTableView.register(orderScanItemNib, forCellReuseIdentifier: orderScanItemCellIdentifier)
  }
  
  override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: "Detail")
  }
  
  @IBAction func didClickFinish(_ sender: UIButton) {
    guard let _orderDetail = orderDetail else {return}
    let status = _orderDetail.statusCode == "OP" ? "IP" : "DV"
    updateOrderStatus(status)
  }
  
  @IBAction func didClickUnableToStart(_ sender: UIButton) {
    performSegue(withIdentifier: SegueIdentifier.showReasonList, sender: nil)
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
  
}

// MARK: - Private methods

extension OrderDetailViewController {
  
  func updateItemStatus(_ status: String, orderItem: OrderItem) {
    APIs.updateOrderItemStatus("\(orderItem.id)", status: status, reason: nil) {
      print("did update status")
    }
  }
  
  func findObject(_ code: String, items: [OrderItem]) -> OrderItem? {
    return items.filter { (item) -> Bool in
      return item.barcode == code
    }.first
  }
  
  func showActionForOrderItem(_ item: OrderItem) {
    let actionSheet = UIAlertController(title: "SRSDriver", message: nil, preferredStyle: .actionSheet)
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let reject = UIAlertAction(title: "Reject", style: .default) { [unowned self] (reject) in
      self.performSegue(withIdentifier: SegueIdentifier.showReasonList, sender: item)
    }
    let management = UIAlertAction(title: "Management", style: .default) { [unowned self] (management) in
      print("management")
    }
    let finish = UIAlertAction(title: "Finish", style: .default) { [unowned self] (finihs) in
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
        self.didUpdateStatus?()
      }
    }
  }
}

extension OrderDetailViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == subTableView {
      let item = detailItems[itemsIndex]
      return scannedString.length > 0 ? 1 : item.items.count
    }
    if let _ = orderDetail {
      return detailItems.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let item = detailItems[indexPath.row]
    if tableView == subTableView {
      return 60.0
    }
    if item.type == .items {
      let itemNumber = scannedString.length > 0 ? 1 : item.items.count
      return item.items.count > 0 ? CGFloat(itemNumber * 60) + 75.0 : 0.0 //75.0 is header for items
    }
    return cellHeight.scaleHeight()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = detailItems[indexPath.row]
    
    if tableView == subTableView  { // subtableview
      if let cell = subTableView.dequeueReusableCell(withIdentifier: orderScanItemCellIdentifier, for: indexPath) as? OrderScanItemTableViewCell {
        let orderItem = detailItems[itemsIndex]
        if scannedString.length > 0,
          let scanObject = findObject(scannedString, items: orderItem.items)
          {
          cell.orderItem = scanObject
        }
        else {
          if indexPath.row < orderItem.items.count {
            cell.orderItem = orderItem.items[indexPath.row]
          }
        }
        return cell
      }
    }
    else if tableView == self.tableView {
      
      if item.type == .items && item.items.count > 0,
        let cell = tableView.dequeueReusableCell(withIdentifier: orderItemsCellIdentifier, for: indexPath) as? OrderItemsTableViewCell {
        let itemNumber = scannedString.length > 0 ? 1 : item.items.count
        subTableView.frame = CGRect(x: 0, y: 75, width: cell.frame.width, height: CGFloat(60*itemNumber))
        cell.contentView.addSubview(subTableView)
        cell.selectionStyle = .none
        cell.didClickScanButton = { [unowned self] () in
          let scanVC = ScanBarCodeViewController.loadViewController(type: ScanBarCodeViewController.self)
          scanVC.didScan = {
            [unowned self] (code) in
            let orderItem = self.detailItems[self.itemsIndex]
            if code.length > 0,
              let _ = self.findObject(code, items: orderItem.items) {
              self.scannedString = code
            }
          }
          self.scannedString = ""
          self.present(scanVC, animated: true, completion: nil)
        }
        return cell
      }
      else if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderDetailTableViewCell {
        cell.orderDetailItem = item
        cell.selectionStyle = !(item.type == .phone && item.type == .address) ? .none : .default
        return cell
      }
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if tableView == subTableView {
      let orderItem = detailItems[itemsIndex]
      showActionForOrderItem(orderItem.items[indexPath.row])
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
