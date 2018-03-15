//
//  LoginViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/14/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {
  
  @IBOutlet weak var userNameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let tk = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String, tk.length > 0 {
      self.performSegue(withIdentifier: SegueIdentifier.showHome, sender: nil)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    view.endEditing(true)
  }
  
  
  @IBAction func didClickLogin(_ sender: UIButton) {
    guard userNameTextField.hasText, passwordTextField.hasText,
      let email = userNameTextField.text,
      let password = passwordTextField.text
      else {
        showAlertView("Invalid info")
        return
    }
    showLoadingIndicator()
    APIs.login(email, password: password) { (token, errorMsg) in
      self.dismissLoadingIndicator()
      guard let tken = token else {
        self.showAlertView(errorMsg ?? "")
        return
      }
      Cache.shared.setObject(obj: tken, forKey: Defaultkey.tokenKey)
      self.performSegue(withIdentifier: SegueIdentifier.showHome, sender: nil)
    }
  }
  
}
