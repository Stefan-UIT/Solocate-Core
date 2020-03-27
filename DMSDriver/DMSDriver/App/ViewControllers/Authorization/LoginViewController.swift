//
//  LoginViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/14/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

enum ChooseEvironment:Int {
    case Development = 0
    case QC
    case Staging
    case Demo
    case Live
    
    var name:String {
        get {
            switch self  {
            case .Development:
                return "Dev"
            case .QC:
                return "QC"
            case .Staging:
                return "Staging"
            case .Demo:
                return "Demo"
            case .Live:
                return "Live"
            }
        }
    }
}

class LoginViewController: BaseViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberButton: UIButton!
    @IBOutlet weak var conBotViewLogin: NSLayoutConstraint?
    @IBOutlet weak var vEvironment: UIView?
    @IBOutlet weak var segEvironmentControl:UISegmentedControl?
    
    //MARK: - Private Variables
    private let DEVELOMENT = 0
    private let QC = 1
    private let DEMO = 2
    private let LIVE = 3
    
    private var keepLogin = true {
        didSet {
            setupRemeberButton()
        }
    }
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupViewEvironment()
        setupRemeberButton()
        
    }
    
    func loadEnvironmentSwichUI() {
        let index = SDBuildConf.currentEnvironment
        segEvironmentControl?.selectedSegmentIndex = index.rawValue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
        loadEnvironmentSwichUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
        self.unregisterForKeyboardNotifications()
        App().statusBarView?.backgroundColor = AppColor.white
    }
    
    override func keyboardWillChangeFrame(noti: Notification) {
        let frame = self.getKeyboardFrameEnd(noti: noti)
        print("Keyboard Frame: \(frame)")
        if frame.minY == ScreenSize.SCREEN_HEIGHT {
            conBotViewLogin?.constant = 0
        }else {
            conBotViewLogin?.constant = -(frame.height / 2.8)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) { (success) in
            //
        }
    }
    
    private func test() {
        userNameTextField.text = "nguyen.manh@seldatinc.com"
        passwordTextField.text = "Seldat.123@"
    }
    
    private func setupViewEvironment() {
        if SDBuildConf.tagetBuild == .Production {
            vEvironment?.isHidden = true
        }else {
            vEvironment?.isHidden = !DMSAppConfiguration.isUseChooseEnvironment
//            segEvironmentControl?.segmentTitles = [ChooseEvironment.Development.name,
//                                                   ChooseEvironment.QC.name,
//                                                   ChooseEvironment.Demo.name]
            segEvironmentControl?.segmentTitles = [ChooseEvironment.Development.name,ChooseEvironment.QC.name]
            segEvironmentControl?.selectedSegmentIndex = 0
        }
    }

    private func setupTextField() {
        userNameTextField.attributedPlaceholder = NSAttributedString(string: userNameTextField.placeholder ?? "",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder ?? "",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
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
    
   private func setupRemeberButton() {
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
    
    @IBAction func onChangeSegmentControl(_ sender: UISegmentedControl) {
        guard let environment = ChooseEvironment(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        switch environment {
        case .Development:
            Debug.setup(shared: Debug(useServer: DMSAppConfiguration.baseUrl_Dev))
        case .QC:
            Debug.setup(shared: Debug(useServer: DMSAppConfiguration.baseUrl_QC))
        case .Staging:
            Debug.setup(shared: Debug(useServer: DMSAppConfiguration.baseUrl_Staging))
        case .Demo:
            Debug.setup(shared: Debug(useServer: DMSAppConfiguration.baseUrl_Demo))
        case .Live:
            Debug.setup(shared: Debug(useServer: DMSAppConfiguration.baseUrl_Product))
        }
        
        UserDefaults.standard.set(environment.rawValue, forKey: "ENVIRONMENT")
        
        print("chosen evironment:\(environment.name)")
        print(#"""
            ====>APPLICATION STARTED WITH:
            TagetBuild: \#(SDBuildConf.tagetBuild.rawValue)
            Server: \#(SDBuildConf.serverUrlString())
            <=====
            """#)
    }
}


//MARK: - APISERVICE
fileprivate extension LoginViewController {
    
    func login(_ userLogin:UserLoginModel)  {
        showLoadingIndicator()
        SERVICES().API.login(userLogin) {[weak self] (result) in
            guard let strongSelf = self else {return}
            strongSelf.dismissLoadingIndicator()

            switch result {
            case .object(let obj):
                
                if obj.data?.isDriver == false {
                    self?.showAlertView("sorry-this-account-is-not-use-as-driver-account-please-contact-your-administrator-for-more-information".localized)
                    return
                }
 
                Caches().user = obj.data
                if self?.keepLogin  ?? false{
                    Caches().userLogin = userLogin;
                }
                
                App().loginSuccess()
                
            case .error(let error):
                self?.dismissLoadingIndicator()
                self?.showAlertView(error.getMessage())
                
            }
        }
    }
    
    func getDrivingRule()  {
        SERVICES().API.getDrivingRule { (result) in
            switch result{
            case .object(let obj):
                Caches().drivingRule = obj
                
            case .error(_ ):
                break
            }
        }
    }
    
}

extension LoginViewController: ForgetPasswordViewDelegate {
    func forgetPasswordView(_ view: ForgetPasswordView, _ email: String) {
        view.removeFromSuperview()
        SERVICES().API.forgotPassword(email) { (result) in
            switch result{
            case .object(_):
                self.showAlertView("Please check email.")
            case .error(let error):
                self.showAlertView(error.getMessage())

            }
        }
    }
}
