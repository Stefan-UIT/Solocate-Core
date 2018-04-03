//
//  RouteMessagesViewController.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 4/2/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class RouteMessagesViewController: UIViewController {
  
  fileprivate let cellIdentifier = "RouteMessageTableViewCell"
  var route: Route?
  
  @IBOutlet weak var addMessageButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    if let _route = route {
      addMessageButton.isHidden = _route.id < 0
    }
  }
  
  @IBAction func addMessage(_ sender: UIButton) {
    guard  let _route = route else {
      return
    }
    let alert = UIAlertController(title: "app_name", message: "message_send_new_message".localized, preferredStyle: .alert)
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
        else if let _note = message {
          //          _route.notes.append(_note)
          //          self.tableView.reloadData()
        }
      })
    }
    
    let cancel = UIAlertAction(title: "cancel".localized, style: .default, handler: nil)
    alert.addAction(cancel)
    alert.addAction(submitAction)
    
    present(alert, animated: true, completion: nil)
  }
}
