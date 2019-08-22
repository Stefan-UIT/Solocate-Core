//
//  ProfileVC.swift
//  DMSDriver
//
//  Created by phunguyen on 7/4/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import SideMenu

class ProfileVC: BaseViewController {
  
    enum ProfileSection:Int {
      case sectionPublic = 0
      case sectionPrivate = 1
    
      static let count: Int = {
        var max: Int = 0
        while let _ = ProfileSection(rawValue: max) { max += 1 }
        return max
      }()
    
    var title:String {
        switch self {
        case .sectionPublic:
        return "Public".localized
        case .sectionPrivate:
        return "Private".localized
        }
      }
    }
  
  
    @IBOutlet weak var imvAvartar:UIImageView?
    @IBOutlet weak var tbvContent:UITableView?
  
    private let  indentifierHeaderCell  = "ProfileHeadetCell"
    private let  indentifierRowCell  = "ProfileEditCell"
    private let  indentifierChangePassCell  = "ProfileChagePassCell"

    private var user:UserModel.UserInfo?
    private var publicInforDatas:[[String]] = []
    private var privateInforDatas:[[String]] = []
  
    private var isEditPublicInfor:Bool = false
    private var isEditPrivateInfor:Bool = false
  
    private var textFieldEdit:UITextField?
    private var changePasswordView : ChangePasswordView!
  

    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setupImageView()
        setupTableView()
        getUserProfile()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    override func updateNavigationBar() {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Menu, "".localized)
        App().navigationService.updateNavigationBar(.Menu,
                                                    "profile".localized,
                                                    AppColor.white, true)
    }
  
    func setupTableView() {
      tbvContent?.delegate = self
      tbvContent?.dataSource = self
    }
  
    func initData() {
        if user == nil {
            user = Caches().user?.userInfo
        }
        publicInforDatas = [["first-name".localized,E(user?.firstName)],
                          ["last-name".localized,E(user?.lastName)]]

        privateInforDatas = [["Phone".localized,E(user?.phone)],
                           ["Email".localized,E(user?.email)],
                           ["Password".localized,"change-password".localized]]
    }
    
    
    func setupImageView() {
        /*
        imvAvartar?.setImageWithURL(url: user?.avatar_thumb,
                                    placeHolderImage: #imageLiteral(resourceName: "ic_nonAvartar"),
                                    complateDownload: { (image, error) in
            //
        })
        */
        
        imvAvartar?.setImage(withURL: E(user?.avatar_thumb), placeholderImage: #imageLiteral(resourceName: "ic_nonAvartar"))
    }

    /*
    // MARK: - Navigation
	
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - ACTION
    @IBAction func onbtnClickChangeAvatar(btn:UIButton) {
        doChangeAvatar()
    }
    
    func doChangeAvatar() {
        ImagePickerView.shared().showImageGallarySinglePick(atVC: self) {[weak self] (success, data) in
            if data.count > 0{
               guard let avartar = data.first , let _user = self?.user else{
                    return
                }
                avartar.param = "avatar"

                self?.changeAvatar(avartar: avartar, user: _user)
            }
        }
    }
}


//MARK: - UITableViewDelegate
extension ProfileVC:UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return ProfileSection.count
  }
    
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let profileSection = ProfileSection(rawValue: section)!
    switch profileSection {
    case .sectionPublic:
      return publicInforDatas.count
    case .sectionPrivate:
      return privateInforDatas.count
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
    
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 35
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let cellHeader = tableView.dequeueReusableCell(withIdentifier: indentifierHeaderCell) as! ProfileCell
    let profileSection = ProfileSection(rawValue: section)!

    cellHeader.lblTitle?.text = profileSection.title
    cellHeader.btnEdit?.tag = section
    cellHeader.delegate = self
    cellHeader.vContent?.roundedCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], 10)

    switch profileSection {
    case .sectionPublic:
      cellHeader.btnEdit?.setImage(!isEditPublicInfor ? #imageLiteral(resourceName: "ic_edit") : nil, for: .normal)
      cellHeader.btnEdit?.setTitle(isEditPublicInfor ? "done".localized : "  \("edit".localized)", for: .normal)
    case .sectionPrivate:
      cellHeader.btnEdit?.setImage(!isEditPrivateInfor ? #imageLiteral(resourceName: "ic_edit") : nil, for: .normal)
      cellHeader.btnEdit?.setTitle(isEditPrivateInfor ? "done".localized : "  \("edit".localized)", for: .normal)
    }
    
    return cellHeader
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    return view
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section
    let row = indexPath.row
    let profileSection = ProfileSection(rawValue: section)!
    var indentifier = indentifierRowCell
    if profileSection == .sectionPrivate && row == 2 { // row change pass
      indentifier = indentifierChangePassCell
    }
    
    let cell:ProfileCell = tableView.dequeueReusableCell(withIdentifier: indentifier, for: indexPath) as! ProfileCell
    
    switch profileSection {
    case .sectionPublic:
      cell.lblTitle?.text = publicInforDatas[row].first
      cell.tfContent?.text = publicInforDatas[row].last
      
      if (self.isEditPublicInfor) {
        cell.lineEdit?.isHidden = false
        if textFieldEdit == cell.tfContent {
          cell.lineEdit?.backgroundColor = AppColor.mainColor
        }else {
          cell.lineEdit?.backgroundColor = AppColor.grayColor
        }
        
      }else {
        cell.lineEdit?.isHidden = true
      }
      
      if publicInforDatas.count - 1 == row {
        cell.vContent?.roundedCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner], 10)
      }else {
        cell.vContent?.roundedCorners([.layerMaxXMinYCorner,
                             .layerMinXMinYCorner,
                             .layerMaxXMaxYCorner,
                             .layerMinXMaxYCorner], 0)
      }

      cell.tfContent?.tag = row
      cell.tfContent?.isUserInteractionEnabled = self.isEditPublicInfor

    case .sectionPrivate:
      cell.lblTitle?.text = privateInforDatas[row].first
      cell.tfContent?.text = privateInforDatas[row].last
      cell.tfContent?.tag = publicInforDatas.count + row
      
      if privateInforDatas.count - 1 == row {
        cell.vContent?.roundedCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner], 10)
        
      }else {
        
        cell.vContent?.roundedCorners([.layerMaxXMaxYCorner,
                                       .layerMaxXMinYCorner,
                                       .layerMinXMaxYCorner,
                                       .layerMinXMinYCorner], 0)
        
      }
      
      if (self.isEditPrivateInfor) {
        
         cell.lineEdit?.isHidden = false
        
        if textFieldEdit == cell.tfContent {
          cell.lineEdit?.backgroundColor = AppColor.mainColor
        }
        else {
          cell.lineEdit?.backgroundColor = AppColor.grayColor
        }
        
      }else {
        cell.lineEdit?.isHidden = true
      }
      cell.tfContent?.isUserInteractionEnabled = self.isEditPrivateInfor
    }

    cell.tfContent?.delegate = self
    cell.selectionStyle = .none
    cell.delegate = self
    
    return cell
  }
}

//MARK: - UITableViewDelegate
extension ProfileVC:ProfileCellDelegate{
  func didSelctEdit(cell: ProfileCell, btn: UIButton) {
    
    if self.isEditPublicInfor ||
      self.isEditPrivateInfor {
      updateUserProfile(user!)
    }
    let profileSection = ProfileSection(rawValue: btn.tag)!
    switch profileSection {
    case .sectionPublic:
      self.isEditPublicInfor = !self.isEditPublicInfor
    case .sectionPrivate:
      self.isEditPrivateInfor = !self.isEditPrivateInfor
    }
    
    self.tbvContent?.reloadData()
  }
  
  func didSelctChagePassword(cell: ProfileCell, btn: UIButton) {
    handleChangePassword()
  }
  
  func handleChangePassword() {
    if (changePasswordView != nil) {
      changePasswordView.resetData()
      changePasswordView.showViewInWindow()
      
    } else {
      changePasswordView = ChangePasswordView()
      changePasswordView.delegate = self
      changePasswordView.showViewInWindow()
    }
  }
}


//MARK: - ChangePasswordViewDelegate
extension ProfileVC : ChangePasswordViewDelegate {
  func changePasswordView(_ view: ChangePasswordView,
                          _ success: Bool,
                          _ errorMessage: String,
                          _ model: ChangePasswordModel?) {
    
    if success {
      view.removeFromSuperview()
      showAlertView(errorMessage)
    } else {
      if let model = model {
        view.removeFromSuperview()
        if model.oldPassword.count > 0 {
          showAlertView(model.oldPassword.first!) { (alertAction) in
            view.showViewInWindow()
          }
        } else if model.newPassword.count > 0 {
          showAlertView(model.newPassword.first!) { (alertAction) in
            view.showViewInWindow()
          }
        }else if model.rePassword.count > 0 {()
          showAlertView(model.rePassword.first!) { (alertAction) in
            view.showViewInWindow()
          }
        } else {
          showAlertView(errorMessage) { (alertAction) in
            view.showViewInWindow()
          }
        }
      } else {
        view.removeFromSuperview()
        showAlertView(errorMessage) { (alertAction) in
          view.showViewInWindow()
        }
      }
    }
  }
}


//MARK: - UITableViewDelegate
extension ProfileVC:UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //
  }
}

//MARK: UITextFieldDelegate
extension ProfileVC:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
      textFieldEdit = textField
      //self.tbvContent?.reloadData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            let tag = textField.tag;
            if tag == 0 {
                user?.firstName = updatedText
            }else if tag == 1 {
                user?.lastName = updatedText
            }else if tag ==  publicInforDatas.count {
                user?.phone = updatedText
            }else if (tag == publicInforDatas.count + 1){
                user?.email = updatedText
            }
        }
        return true
    }
}


//MARK: -DMSNavigationServiceDelegate
extension ProfileVC:DMSNavigationServiceDelegate{
    func didSelectedMenuAction() {
        showSideMenu()
    }
}

//MARK: - API
extension ProfileVC{
  func getUserProfile() {
    if ReachabilityManager.isNetworkAvailable {
        self.showLoadingIndicator()
        SERVICES().API.getUserProfile {[weak self] (result) in
            guard let strongSelf = self else{return}
            strongSelf.dismissLoadingIndicator()
            switch result{
            case .object(let obj):
                strongSelf.user = obj.data;
                strongSelf.initData()
                strongSelf.setupImageView()
                strongSelf.tbvContent?.reloadData()
                break
            case .error(let error):
                strongSelf.showAlertView(error.getMessage())
                break
            }
        }
    }else {
        user = Caches().user?.userInfo
        initData()
        tbvContent?.reloadData()
    }
  }
  
  func updateUserProfile(_ user:UserModel.UserInfo) {
    self.showLoadingIndicator()
    SERVICES().API.updateUserProfile(user) {[weak self] (result) in
      guard let strongSelf = self else{return}
      strongSelf.dismissLoadingIndicator()
      switch result{
      case .object(let obj):
        strongSelf.user = obj.data;
        strongSelf.initData()
        strongSelf.tbvContent?.reloadData()
        strongSelf.showAlertView("updated-successful".localized)
        let user = Caches().user
        user?.userInfo = obj.data
        Caches().user = user

      case .error(let error):
        strongSelf.showAlertView(error.getMessage())
      }
    }
  }
    
    func changeAvatar(avartar:AttachFileModel, user:UserModel.UserInfo)  {
        self.showLoadingIndicator()
        SERVICES().API.changeAvatarUser("\(user.id)", avartar) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result {
            case .object(let obj):
                self?.user = obj.data
                self?.setupImageView()
                let user = Caches().user
                user?.userInfo = obj.data
                Caches().user = user
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
                break
            }
        }
    }
}
