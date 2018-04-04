//
//  RouteMessagesViewController.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 4/2/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class RouteMessagesViewController: BaseViewController {
  
  fileprivate let cellIdentifier = "RouteMessageTableViewCell"
  private let estimatedRowHeight: CGFloat = 80.0
  var route: Route? {
    didSet {
      guard let _ = route, tableView != nil else {
        return
      }
      tableView.reloadData()
//      showLoadingIndicator()
//      MessageAPI.getList("\(_route.id)") { [weak self] (resp, errMsg) in
//        self?.dismissLoadingIndicator()
//        if let _messages = resp {
//          self?.messages.removeAll()
//          self?.messages.append(contentsOf: _messages)
//          self?.tableView.reloadData()
//          self?.tabBarController?.tabBar.selectedItem?.badgeValue = "\(_messages.count)"
//        }
//        else if let _msg = errMsg {
//          self?.showAlertView(_msg)
//        }
//      }
    }
  }
  
  @IBOutlet weak var addMessageButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  fileprivate var messages = [Message]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let _route = route {
      addMessageButton.isHidden = _route.id < 0
    }
    tableView.estimatedRowHeight = estimatedRowHeight
    tableView.rowHeight = UITableViewAutomaticDimension
    
  }
  
  @IBAction func addMessage(_ sender: UIButton) {
    guard  let _route = route else {
      return
    }
    let alert = UIAlertController(title: "app_name".localized, message: "message_send_new_message".localized, preferredStyle: .alert)
    alert.addTextField { (textField) in
      textField.placeholder = "message_add_message_hint".localized
    }
    let submitAction = UIAlertAction(title: "send".localized, style: .default) { (action) in
      alert.dismiss(animated: true, completion: nil)
      guard let textField = alert.textFields?.first,
        textField.hasText,
        let noteText = textField.text else {
          return
      }
      self.showLoadingIndicator()
      MessageAPI.addNewMessage("\(_route.id)", content: noteText, completion: { [weak self] (message, errMsg) in
        self?.dismissLoadingIndicator()
        if let err = errMsg {
          self?.showAlertView(err)
        }
        else if let _message = message {
          _route.messages.insert(_message, at: 0)
          if let item = self?.tabBarController?.tabBar.items?.last {
            let current = item.badgeValue?.integerValue ?? 0
            item.badgeValue = "\(current + 1)"
          }
          self?.tableView.reloadData()
        }
      })
    }
    
    let cancel = UIAlertAction(title: "cancel".localized, style: .default, handler: nil)
    alert.addAction(cancel)
    alert.addAction(submitAction)
    
    present(alert, animated: true, completion: nil)
  }
}

extension RouteMessagesViewController {
  
}

extension RouteMessagesViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let _route = route {
      return _route.messages.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let _route = route else {
      return UITableViewCell()
    }
    if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RouteMessageTableViewCell {
      cell.message = _route.messages[indexPath.row]
      return cell
    }
    
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

}
