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
  @IBOutlet weak var enviromentButton: UIButton!
    
    private var keepLogin = true {
        didSet {
            setupRemeberButton()
        }
    }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    enviromentButton.isHidden = true
    setupTextField()
    setupRemeberButton()
  }
    
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
    
  func test() {
    userNameTextField.text = "nguyen.manh@seldatinc.com"
    passwordTextField.text = "Seldat.123@"
  }

  func setupTextField() {
    let isRemember = Caches().getObject(forKey: Defaultkey.keepLogin)
    if let remember =  isRemember as? Bool {
        if remember{
            userNameTextField.text = Caches().userLogin?.email
            passwordTextField.text = Caches().userLogin?.password
        }else {
            userNameTextField.text = nil
            passwordTextField.text = nil
        }
    }
  }
    
   func setupRemeberButton() {
     let imgName = keepLogin ? "check_selected" : "check_normal"
      rememberButton.setImage(UIImage(named: imgName), for: .normal)
      Caches().setObject(obj: keepLogin, forKey: Defaultkey.keepLogin)
    }
    
  
  func handleForgetPassword() {
    let forgetPasswordView : ForgetPasswordView = ForgetPasswordView()
    forgetPasswordView.delegate = self
    forgetPasswordView.showViewInView(superView: self.view)
  }
    
    
  //MARK: - ACTION
  @IBAction func didClickRemember(_ sender: UIButton) {
    keepLogin = !keepLogin
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
    
    let userLogin = UserLoginModel(email,password);
    login(userLogin)
  }
   
    
  @IBAction func tapForgetPasswordButtonAction(_ sender: UIButton) {
    handleForgetPassword()
  }
    
  
  @IBAction func tapEnviromentButtonAction(_ sender: UIButton) {
    
  }
}


//MARK: - APISERVICE
fileprivate extension LoginViewController {
    
    func login(_ userLogin:UserLoginModel)  {
        showLoadingIndicator()
        API().login(userLogin) {[weak self] (result) in
            switch result {
            case .object(let user):
                Caches().user = user // need to set, cause need token to call getUserProfile
                if self?.keepLogin  ?? false{
                    Caches().userLogin = userLogin;
                }
                API().getUserProfile(callback: { [weak self] (response) in
                    self?.dismissLoadingIndicator()
                    switch response {
                    case .object(let obj):
                        if let x = obj.data {
                            user.userID = x.userID
                            Caches().user = user
                        } // just need to get userID atm.
                        break
                    case .error(_):
                        break
                    }
                    App().loginSuccess()
                })
                
            case .error(let error):
                self?.dismissLoadingIndicator()
                self?.showAlertView(error.getMessage())
                
            }
        }
    }
}


extension LoginViewController: ForgetPasswordViewDelegate {
    func forgetPasswordView(_ view: ForgetPasswordView, _ email: String) {
        view.removeFromSuperview()
        API().forgotPassword(email) { (result) in
            switch result{
            case .object(_):
                self.showAlertView("Please check email.")
            case .error(let error):
                self.showAlertView(error.getMessage())

            }
        }
    }
}
