//
//  OrderNotesViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class OrderNotesViewController: BaseOrderDetailViewController {
  
  fileprivate let cellIdentifier = "NoteTableViewCell"
  fileprivate let cellHeight: CGFloat = 90.0
  override var orderDetail: OrderDetail? {
    didSet {
      guard tableView != nil else {return}
      tableView.reloadData()
    }
  }
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()    
  }
  
  override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: "order_detail_notes".localized)
  }
  
  
  @IBAction func addNote(_ sender: UIButton) {
    guard  let _orderDetail = orderDetail else {
      return
    }
    let alert = UIAlertController(title: "order_detail_add_note".localized, message: nil, preferredStyle: .alert)
    alert.addTextField { (textField) in
      textField.placeholder = "order_detail_add_note".localized
    }
    let submitAction = UIAlertAction(title: "send".localized, style: .default) { (action) in
      alert.dismiss(animated: true, completion: nil)
      guard let textField = alert.textFields?.first,
        textField.hasText,
        let noteText = textField.text else {
        return
      }
      self.showLoadingIndicator()
      APIs.addNote("\(_orderDetail.id)", content: noteText, completion: { [unowned self] (note, errorMsg) in
        self.dismissLoadingIndicator()
        if let err = errorMsg {
          self.showAlertView(err)
        }
        else if let _note = note {
          _orderDetail.notes.append(_note)
          self.tableView.reloadData()
        }
      })
      
    }
    let cancel = UIAlertAction(title: "cancel".localized, style: .default, handler: nil)
    alert.addAction(cancel)
    alert.addAction(submitAction)
    present(alert, animated: true, completion: nil)
  }
  
}

extension OrderNotesViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let _order = orderDetail {
      return _order.notes.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NoteTableViewCell, let order = orderDetail {
      cell.note = order.notes[indexPath.row]
      return cell
    }
    return UITableViewCell()
  }
}
