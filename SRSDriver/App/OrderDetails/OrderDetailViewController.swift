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
  
  fileprivate var detailItems = [OrderDetailItem]()
  fileprivate let cellHeight: CGFloat = 70.0
  fileprivate let cellIdentifier = "OrderDetailTableViewCell"
  
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
      
      detailItems.append(refe)
      detailItems.append(status)
      detailItems.append(delDate)
      detailItems.append(customer)
      detailItems.append(phone)
      detailItems.append(address)
      detailItems.append(description)
      tableView.reloadData()
      // MARK: - FIX ME
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
    }
  }
  
}

extension OrderDetailViewController {
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
    if let _ = orderDetail {
      return detailItems.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight.scaleHeight()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderDetailTableViewCell {
      cell.orderDetailItem = detailItems[indexPath.row]
      return cell
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
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
