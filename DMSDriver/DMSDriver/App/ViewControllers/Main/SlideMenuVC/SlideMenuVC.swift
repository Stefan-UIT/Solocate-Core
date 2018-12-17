
import UIKit

enum MenuItemType : Int {
  
  case PROFILE = 0
  case ROUTES
  case COUNTER
  case ASSIGN
  case TASK
  case LOGOUT
  
  static let count: Int = {
    var max: Int = 0
    while let _ = MenuItemType(rawValue: max) { max += 1 }
    return max
  }()
  
  func title() -> String? {
    switch self {
    case .PROFILE:
      return ""
    case .ROUTES:
        return "Routes".localized.uppercased()
    case .COUNTER:
        return "Counter".localized.uppercased()
    case .ASSIGN:
        return "Orders assignment".localized.uppercased()
    case .TASK:
        return "Tasks List".localized.uppercased()
    case .LOGOUT:
      return "Logout".localized.uppercased()
    }
  }
  
  func normalIcon() -> UIImage? {
    switch self {
    case .PROFILE:
      return #imageLiteral(resourceName: "ic_avartar")
    case .ROUTES:
      return #imageLiteral(resourceName: "ic_route")
    case .COUNTER:
        return UIImage(named: "ic_alarm-clock")
    case .ASSIGN:
        return #imageLiteral(resourceName: "ic_orderlist")
    case .TASK:
        return #imageLiteral(resourceName: "Menu_Task")
    case .LOGOUT:
      return #imageLiteral(resourceName: "ic_logout")
    }
  }
}


class SlideMenuVC: BaseViewController {
  
  @IBOutlet weak var tbvContent:UITableView?
  
  fileprivate let profileIndentifierCell = "SlideMenuAvartarCell"
  fileprivate let rowIndentifierCell = "SlideMenuRowCell"
  
  var currentItem:MenuItemType = .ROUTES
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTableView()
  }
  
  func setupTableView() {
    tbvContent?.delegate = self
    tbvContent?.dataSource = self
  }

}

extension SlideMenuVC: UITableViewDataSource{
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if let menutype:MenuItemType = MenuItemType(rawValue: indexPath.row) {
        if menutype == .ASSIGN ||
            menutype == MenuItemType.TASK {
            return 0
        }
    }
    return UITableViewAutomaticDimension
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return MenuItemType.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let menutype:MenuItemType = MenuItemType(rawValue: indexPath.row)!

    let indentifier = menutype == .PROFILE ? profileIndentifierCell : rowIndentifierCell
    let cell:SlideMenuCell = tableView.dequeueReusableCell(withIdentifier: indentifier, for: indexPath) as! SlideMenuCell
    
    cell.menuType = menutype
    if menutype == currentItem {
        cell.imvIcon?.tintColor = AppColor.mainColor
        cell.lblTitle?.textColor = AppColor.mainColor
    }else{
        cell.imvIcon?.tintColor = AppColor.grayBorderColor
        cell.lblTitle?.textColor = AppColor.grayBorderColor
    }
    
    cell.selectionStyle = .none;
    
    return cell
  }
}

extension SlideMenuVC:UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let menuType = MenuItemType(rawValue: indexPath.row){
      if currentItem != menuType{
        currentItem = menuType
        switch menuType {
        case .PROFILE:
            let vc:ProfileVC = .loadSB(SB: .Profile)
            App().mainVC?.rootNV?.setViewControllers([vc], animated: false)

        case .ROUTES:
            App().mainVC?.pushRouteListVC()
            
        case .COUNTER:
            let vc:TimerVC = .loadSB(SB: SBName.Packages)
            App().mainVC?.rootNV?.setViewControllers([vc], animated: false)

        case .ASSIGN:
            let vc:AssignOrderVC = .loadSB(SB: .Order)
            App().mainVC?.rootNV?.setViewControllers([vc], animated: false)

        case .LOGOUT:
            DispatchQueue.main.async {
                self.navigationController?.dismiss(animated: false, completion: {
                    self.handleLogOut()
                })
            }
        case .TASK:
            let vc:TaskListVC = .loadSB(SB: .Task)
            App().mainVC?.rootNV?.setViewControllers([vc], animated: false)
        }
      }
      if (currentItem != .LOGOUT){
        DispatchQueue.main.async {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
      }
      self.tbvContent?.reloadData()
    }
  }
}

//MARK: API
private extension SlideMenuVC{
    func handleLogOut() {
        App().reLogin()
        API().logout { (result) in
            switch result{
            case .object(_):
            Caches().user = nil
            case .error(let error):
            self.showAlertView(error.getMessage())
            }
        }
    }
}

