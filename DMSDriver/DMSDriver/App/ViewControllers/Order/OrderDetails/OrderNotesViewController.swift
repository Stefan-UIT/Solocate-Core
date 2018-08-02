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
    //
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
