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
  
  
  @IBAction func didClickLogin(_ sender: UIButton) {
    guard userNameTextField.hasText, passwordTextField.hasText,
      let _ = userNameTextField.text,
      let _ = passwordTextField.text
      else {
        showAlertView("Invalid info")
        return
    }
    performSegue(withIdentifier: SegueIdentifier.showHome, sender: nil)
  }

}
