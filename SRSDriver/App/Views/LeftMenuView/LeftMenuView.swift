//
//  LeftMenuView.swift
//  DMSDriver
//
//  Created by MrJ on 4/17/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

enum IdentifierType : Int {
    case CHANGE_INVIROMENT = 0
    case CHANGE_PASSWORD = 1
    case LOG_OUT = 2
}

protocol LeftMenuViewDelegate: class {
  func leftMenuView(_ view: LeftMenuView, _ selectedItem: IdentifierType)
}

class LeftMenuView: BaseView {
  
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var tableView: UITableView!
  
  var isDisplayed = false
  weak var delegate : LeftMenuViewDelegate? = nil
  
  
  override func config() {
    super.config()
    tableView.register(UINib(nibName: getIndentifier(.LOG_OUT), bundle: nil), forCellReuseIdentifier: getIndentifier(.LOG_OUT))
    
    tableView.register(UINib(nibName: getIndentifier(.CHANGE_PASSWORD), bundle: nil), forCellReuseIdentifier: getIndentifier(.CHANGE_PASSWORD))
    
    tableView.register(UINib(nibName: getIndentifier(.CHANGE_INVIROMENT), bundle: nil), forCellReuseIdentifier: getIndentifier(.CHANGE_INVIROMENT))
    
    tableView.estimatedRowHeight = 50.0
    tableView.rowHeight = UITableViewAutomaticDimension
  }
  
  override func showViewInView(superView: UIView, isHiddenStatusBar: Bool?) {
    super.showViewInView(superView: superView, isHiddenStatusBar: isHiddenStatusBar)
    self.layoutIfNeeded()
    self.alpha = 0.0
    var frame = self.contentView.frame
    frame.origin.x -= frame.width
    self.contentView.frame = frame
    UIView.animate(withDuration: 0.25, animations: {
      self.alpha = 1.0
      frame.origin.x += frame.width
      self.contentView.frame = frame
    }) { (finish) in
      self.isDisplayed = true
    }
  }
  
  func hideView() {
    self.layoutIfNeeded()
    var frame = self.contentView.frame
    frame.origin.x -= frame.width
    UIView.animate(withDuration: 0.25, animations: {
      self.alpha = 0.0
      self.contentView.frame = frame
    }) { (finish) in
      self.isDisplayed = false
      super.removeFromSuperview()
    }
  }
  
  //MARK: Action
  @IBAction func tapbackgroundButtonAction(_ sender: UIButton) {
    hideView()
  }
}

//MARK: Extension
extension LeftMenuView {
    func getIndentifier(_ type: IdentifierType) -> String {
        switch type {
        case .LOG_OUT:
            return "LogoutTableViewCell"
        case .CHANGE_PASSWORD:
            return "ChangePasswordTableViewCell"
        case .CHANGE_INVIROMENT:
            return "ChangeInviromentTableViewCell"
        }
    }
}

//MARK: Extension - UITableView
extension LeftMenuView : UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier = getIndentifier(IdentifierType(rawValue: indexPath.row)!)
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
      return UITableViewCell()
    }
    return cell
  }
}

extension LeftMenuView : UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    let identifier = IdentifierType(rawValue: indexPath.row)
    if delegate != nil {
        delegate?.leftMenuView(self, identifier!)
    }
  }
}
