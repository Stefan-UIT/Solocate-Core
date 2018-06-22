//
//  PackagesViewController.swift
//  DMSDriver
//
//  Created by Nguyen Phu on 4/6/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class PackagesViewController: BaseViewController {
  
  @IBOutlet weak var tableView: UITableView!
  fileprivate let cellIdentifier = "PackageTableViewCell"
  fileprivate let cellHeight: CGFloat = 80.0
  
  var route: Route? {
    didSet {
      guard let _ = route, tableView != nil else {
        return
      }
      tableView.reloadData()
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "packages".localized
  }
  
}

extension PackagesViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let _route = route {
      return _route.currentItems.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PackageTableViewCell
        else { return UITableViewCell() }
    if let _route = route {
        cell.item = _route.currentItems[indexPath.row]
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight.scaleHeight()
  }
  
}
