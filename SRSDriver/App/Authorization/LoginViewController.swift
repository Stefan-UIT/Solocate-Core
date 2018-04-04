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
  @IBOutlet weak var rememberButton: UIButton!
  private var keepLogin = true
  override func viewDidLoad() {
    super.viewDidLoad()
    if let _keepLogin = Cache.shared.getObject(forKey: Defaultkey.keepLogin) as? Bool {
      let imgName = _keepLogin ? "check_selected" : "check_normal"
      rememberButton.setImage(UIImage(named: imgName), for: .normal)
      keepLogin = _keepLogin
    }
    else {
      Cache.shared.setObject(obj: true, forKey: Defaultkey.keepLogin)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard let keepLogin = Cache.shared.getObject(forKey: Defaultkey.keepLogin) as? Bool, keepLogin == true else {
      return
    }
    if let tk = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String, tk.length > 0 {
      self.performSegue(withIdentifier: SegueIdentifier.showHome, sender: nil)
    }
  }
  @IBAction func didClickRemember(_ sender: UIButton) {
    keepLogin = !keepLogin
    let imgName = keepLogin ? "check_selected" : "check_normal"
    rememberButton.setImage(UIImage(named: imgName), for: .normal)
    Cache.shared.setObject(obj: keepLogin, forKey: Defaultkey.keepLogin)
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
        showAlertView("error_fill_info".localized)
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
