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
      //
//      let unreadMessages = _route.messages.filter{ $0.status < 1}
      //call read unread message
//      readMessages(unreadMessages)
    }
  }
    
  var alertID: Int? {
    didSet {
        
    }
  }
  
  var listAlertMessage = [AlertDetailModel]()
    
  @IBOutlet weak var tableView: UITableView!
  fileprivate var messages = [Message]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = estimatedRowHeight
    tableView.rowHeight = UITableViewAutomaticDimension
    title = "messages".localized
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = false
    loadData()
  }
  
  func loadData() {
    //
  }
    
  func updateData() {
    tableView.reloadData()
  }
    
  @IBAction func addMessage(_ sender: UIButton) {
    guard  let _route = route else {
      return
    }
    let alert = UIAlertController(title: "message_send_new_message".localized, message: nil, preferredStyle: .alert)
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
//          if let item = self?.tabBarController?.tabBar.items?.last {
//            let current = item.badgeValue?.integerValue ?? 0
//            item.badgeValue = "\(current + 1)"
//          }
          self?.tableView.reloadData()
        }
      })
    }
    
    let cancel = UIAlertAction(title: "cancel".localized, style: .default, handler: nil)
    alert.addAction(cancel)
    alert.addAction(submitAction)
    
    present(alert, animated: true, completion: nil)
  }
    
  func handleAlert(_ alertID: String, _ messageAlert: String) {

        let alertMessageView : AlertMessageView = AlertMessageView()
        alertMessageView.delegate = self
        alertMessageView.config(alertID, messageAlert)
        alertMessageView.showViewInWindow()
  }
}

extension RouteMessagesViewController {
  func readMessages(_ messages: [Message]) {
    for msg in messages {
      MessageAPI.readMessage("\(msg.id)")
    }
  }
}

extension RouteMessagesViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return listAlertMessage.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RouteMessageTableViewCell {
      cell.alertDetail = listAlertMessage[indexPath.row]
      return cell
    }
    
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let model = listAlertMessage[indexPath.row]
        guard let alertID = model.id else {
            return
        }
        guard let messageAlert = model.alertMsg else {
            return
        }
        handleAlert("\(alertID)", messageAlert)
    }
}

extension RouteMessagesViewController: AlertMessageViewDelegate {
    func alertMessageView(_ alertMessageView: AlertMessageView, _ alertID: String, _ content: String) {
        //
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Done", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
