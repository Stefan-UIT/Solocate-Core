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
    //
  }

  func handleAlert(_ alertID: String, _ messageAlert: String) {

        let alertMessageView : AlertMessageView = AlertMessageView()
        alertMessageView.delegate = self
        alertMessageView.config(alertID, messageAlert)
        alertMessageView.showViewInWindow()
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
