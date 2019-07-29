
import UIKit

enum MenuItemType : Int {
  
  case PROFILE = 0
  case DASHBOARD
  case ROUTES
  case COUNTER
  case ASSIGN
  case TASK
  case ALERT
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
    case .DASHBOARD:
        return "dashboard".localized.uppercased()
    case .ROUTES:
        return "Routes".localized.uppercased()
    case .COUNTER:
        return "Counter".localized.uppercased()
    case .ASSIGN:
        return "orders-assignment".localized.uppercased()
    case .TASK:
        return "tasks-list".localized.uppercased()
    case .ALERT:
        return "Alerts".localized.uppercased()
    case .LOGOUT:
      return "Logout".localized.uppercased()
    }
  }
  
  func normalIcon() -> UIImage? {
    switch self {
    case .PROFILE:
      return #imageLiteral(resourceName: "ic-DefaultUser")
    case .DASHBOARD:
      return #imageLiteral(resourceName: "ic_route")
    case .ROUTES:
      return #imageLiteral(resourceName: "ic_route")
    case .COUNTER:
        return UIImage(named: "ic_alarm-clock")
    case .ASSIGN:
        return #imageLiteral(resourceName: "ic_orderlist")
    case .TASK:
        return #imageLiteral(resourceName: "Menu_Task")
    case .ALERT:
        return #imageLiteral(resourceName: "ic_notifyBlue")
    case .LOGOUT:
      return #imageLiteral(resourceName: "ic_logout")
    }
  }
}


class SlideMenuVC: BaseViewController {
  
    @IBOutlet weak var tbvContent:UITableView?

    fileprivate let profileIndentifierCell = "SlideMenuAvartarCell"
    fileprivate let rowIndentifierCell = "SlideMenuRowCell"

    var currentItem:MenuItemType = .DASHBOARD

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tbvContent?.reloadData()
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
        if menutype == .LOGOUT {
            return MAX(ScreenSize.SCREEN_HEIGHT - (CGFloat(((MenuItemType.count - 2) * 65)) + 200), 65)
        }
        if menutype == .ASSIGN {
            return 0
        }
        
        if isRampManagerMode {
            switch menutype {
                case .DASHBOARD, .COUNTER, .ALERT:
                    return 0
                default:
                    break
            }
        }
    }
    
    return UITableView.automaticDimension
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
    
    cell.configura(menuType:menutype,selectedType: currentItem)

    return cell
  }
}

extension SlideMenuVC:UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let menuType = MenuItemType(rawValue: indexPath.row) else {
        return
    }
    
    if currentItem != menuType{
        currentItem = menuType
        switch menuType {
        case .PROFILE:
            let vc:ProfileVC = .loadSB(SB: .Profile)
            App().mainVC?.rootNV?.setViewControllers([vc], animated: false)
            
        case .DASHBOARD:
            let vc:DashboardVC = .loadSB(SB: .Dashboard)
            App().mainVC?.rootNV?.setViewControllers([vc], animated: false)
            
        case .ROUTES:
            App().mainVC?.pushRouteListVC()
            
        case .COUNTER:
            let vc:TimerVC = .loadSB(SB: SBName.Packages)
            App().mainVC?.rootNV?.setViewControllers([vc], animated: false)
            
        case .ASSIGN:
            let vc:AssignOrderVC = .loadSB(SB: .Order)
            App().mainVC?.rootNV?.setViewControllers([vc], animated: false)
    
        case .TASK:
            let vc:TaskListVC = .loadSB(SB: .Task)
            App().mainVC?.rootNV?.setViewControllers([vc], animated: false)
            
        case .ALERT:
            let vc:HistoryNotifyVC = .loadSB(SB: .Notification)
            App().mainVC?.rootNV?.setViewControllers([vc], animated: false)
            
        case .LOGOUT:
            DispatchQueue.main.async {
                self.navigationController?.dismiss(animated: false, completion: {
                    self.handleLogOut()
                })
            }
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

//MARK: API
private extension SlideMenuVC{
    func handleLogOut() {
        App().reLogin()
        SERVICES().API.logout { (result) in
            switch result{
            case .object(_):
            Caches().user = nil
            case .error(let error):
            self.showAlertView(error.getMessage())
            }
        }
    }
}

