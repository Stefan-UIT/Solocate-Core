//
//  LeftMenuView.swift
//  DMSDriver
//
//  Created by MrJ on 4/17/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

protocol LeftMenuViewDelegate: class {
  func leftMenuView(_ view: LeftMenuView, _ isLogout: Bool)
}

class LeftMenuView: BaseView {
  
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var tableView: UITableView!
  fileprivate let logoutIdentifier = "LogoutTableViewCell"
  
  var isDisplayed = false
  weak var delegate : LeftMenuViewDelegate? = nil
  
  
  override func config() {
    super.config()
    tableView.register(UINib(nibName: logoutIdentifier, bundle: nil), forCellReuseIdentifier: logoutIdentifier)
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
extension LeftMenuView : UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let logoutCell = tableView.dequeueReusableCell(withIdentifier: logoutIdentifier) else {
      return UITableViewCell()
    }
    return logoutCell
  }
}

extension LeftMenuView : UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if delegate != nil {
      delegate?.leftMenuView(self, true)
    }
  }
}
