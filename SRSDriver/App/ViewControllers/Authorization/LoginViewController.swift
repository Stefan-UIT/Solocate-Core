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
    updateStatusEnviroment()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard let keepLogin = Cache.shared.getObject(forKey: Defaultkey.keepLogin) as? Bool, keepLogin == true else {
      return
    }
    if let tk = Cache.shared.getObject(forKey: Defaultkey.tokenKey) as? String, tk.length > 0 {
        showLoadingIndicator()
        APIs.checkToken { (isValid, message) in
            self.dismissLoadingIndicator()
            if isValid {
                self.performSegue(withIdentifier: SegueIdentifier.showHome, sender: nil)
            }
        }
    }
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
    
  
  func updateStatusEnviroment() {
        let type = DataManager.getEnviroment()
        switch type {
        case .DEMO:
            enviromentButton.setTitle("Demo", for: .normal)
            break
        case .DEV:
            enviromentButton.setTitle("Developer", for: .normal)
            break
        }
  }
    
  func handleForgetPassword() {
    let forgetPasswordView : ForgetPasswordView = ForgetPasswordView()
    forgetPasswordView.delegate = self
    forgetPasswordView.showViewInView(superView: self.view)
  }
    
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
        DataManager.changeEnviroment()
        updateStatusEnviroment()
    }
}


//MARK: - APISERVICE
fileprivate extension LoginViewController {
    
    func login(_ userLogin:UserLoginModel)  {
        showLoadingIndicator()
        API().login(userLogin) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(let obj):
                
                Caches().user = obj
                if self?.keepLogin  ?? false{
                    Caches().userLogin = userLogin;
                }
                self?.performSegue(withIdentifier: SegueIdentifier.showHome, sender: nil)
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
                
            }
        }
    }
}


extension LoginViewController: ForgetPasswordViewDelegate {
    func forgetPasswordView(_ view: ForgetPasswordView, _ email: String) {
        view.removeFromSuperview()
        APIs.forgetPassword(email) { [unowned self] (msg, error) in
            if let msg = msg {
                self.showAlertView(msg)
            } else if let error = error {
                self.showAlertView(error)
            } else {
                self.showAlertView("Something Wrong.")
            }
        }
    }
}
