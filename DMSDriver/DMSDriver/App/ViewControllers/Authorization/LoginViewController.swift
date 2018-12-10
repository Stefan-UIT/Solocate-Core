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
    
    private var keepLogin = true {
        didSet {
            setupRemeberButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupRemeberButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Socket.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
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
}


//MARK: - APISERVICE
fileprivate extension LoginViewController {
    
    func login(_ userLogin:UserLoginModel)  {
        showLoadingIndicator()
        API().login(userLogin) {[weak self] (result) in
            switch result {
            case .object(let obj):
                Caches().user = obj.data
                if self?.keepLogin  ?? false{
                    Caches().userLogin = userLogin;
                }
                App().loginSuccess()
                
                SERVICES().API.getDrivingRule { (result) in
                    guard let strongSelf = self else {return}
                    strongSelf.dismissLoadingIndicator()
                    switch result{
                    case .object(let obj):
                        
                        let data = DrivingRule()
                        data.data = 1
                        Caches().drivingRule = data
 
                    case .error(let error):
                        strongSelf.showAlertView(error.getMessage())
                    }
                }

                // Fetch reasons save to local DB
                //self?.getReasonList()
                self?.getListStatus()
                
            case .error(let error):
                self?.dismissLoadingIndicator()
                self?.showAlertView(error.getMessage())
                
            }
        }
    }
    
    func getListStatus()  {
        SERVICES().API.getListStatus { (result) in
            switch result{
            case .object(let obj):
                guard let list = obj.data?.data else {return}
                CoreDataManager.updateListStatus(list)
            case .error(_ ):
                break
            }
        }
    }
    
    func getReasonList() {
        API().getReasonList {(result) in
            switch result{
            case .object(let obj):
                guard let list = obj.data?.data else {return}
                CoreDataManager.updateListReason(list) // Update reason list to local DB
            case .error(_):
                break
            }
        }
    }
}

extension LoginViewController:APISocketDelegate{
    func didReceiveResultLogin(data: Any) {
        let mess = getMessengeStatus(data: data).0
        let status = getMessengeStatus(data: data).1
        
        if status == 1 {// Success
            App().loginSuccess()
            
        }else{ //Users limited.
            self.showAlertView(E(mess))
            App().reLogin()
        }
    }
    
    func getMessengeStatus(data:Any) -> (String?,Int?) {
        if let dic = (data as? ResponseDictionary){
            let status = dic["status"] as? Int
            let mess = dic["message"] as? String
            return (mess,status)
        
        }else if let dicList = (data as? ResponseArray){
            if let dic = dicList.first as? ResponseDictionary{
                let status = dic["status"] as? Int
                let mess = dic["message"] as? String
                return (mess,status )
            }
        }
        
        return ("Data response is invalid.",-1)
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
