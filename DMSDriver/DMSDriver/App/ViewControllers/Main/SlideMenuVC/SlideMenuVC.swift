
import UIKit

enum MenuItemType : Int {
  
  case PROFILE = 0
  case DASHBOARD
  case ROUTES
  case COUNTER
  case RENTINGORDERS
  case TASK
    case RETURNEDITEMS
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
    case .RENTINGORDERS:
        return "renting-orders".localized.uppercased()
    case .TASK:
        return "tasks-list".localized.uppercased()
    case .RETURNEDITEMS:
        return "returned-items".localized.uppercased()
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
    case .RENTINGORDERS:
        return #imageLiteral(resourceName: "ic_orderlist")
    case .TASK:
        return #imageLiteral(resourceName: "Menu_Task")
    case .RETURNEDITEMS:
        return #imageLiteral(resourceName: "Menu_Task")
    case .ALERT:
        return #imageLiteral(resourceName: "ic_notifyBlue")
    case .LOGOUT:
      return #imageLiteral(resourceName: "ic_logout")
    }
  }
}


class SlideMenuVC: BaseViewController {
  
    @IBOutlet weak var buildVersionLabel: UILabel!
    @IBOutlet weak var tbvContent:UITableView?

    fileprivate let profileIndentifierCell = "SlideMenuAvartarCell"
    fileprivate let rowIndentifierCell = "SlideMenuRowCell"

    var currentItem:MenuItemType = .DASHBOARD
    var returnedItemTimeDataManager = TimeData()
    var taskTimeDataManager = TimeData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setUpVersionLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tbvContent?.reloadData()
    }
    
    func getAppInfo()-> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return version + "(" + build + ")"
    }
    
    func setUpVersionLabel() {
        let buildVersion = getAppInfo()
        let text = "Version".localized + ": " + buildVersion
        buildVersionLabel.text = text
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
        if menutype == .DASHBOARD || menutype == .COUNTER || menutype == .ALERT || menutype == .RETURNEDITEMS || menutype == .TASK {
            return 0
        }
        
//        if isRampManagerMode {
//            switch menutype {
//                case .COUNTER, .ALERT:
//                    return 0
//                default:
//                    break
//            }
//        }
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
            
        case .RENTINGORDERS:
//            let vc:AssignOrderVC = .loadSB(SB: .Order)
            let vc:RentingOrderListVC = .loadSB(SB: .RentingOrder)
            App().mainVC?.rootNV?.setViewControllers([vc], animated: false)
    
        case .TASK:
            let vc:TaskListVC = .loadSB(SB: .Task)
            
            if let _timeData = taskTimeDataManager.getTimeDataItemDefault() {
                vc.selectedTimeData = _timeData
            } else {
                vc.selectedTimeData = taskTimeDataManager.getTimeDataItemType(type: .TimeItemTypeToday)
                taskTimeDataManager.setTimeDataItemDefault(item: vc.selectedTimeData!)
            }
            App().mainVC?.rootNV?.setViewControllers([vc], animated: false)
        case .RETURNEDITEMS:
            let vc:ReturnedItemsListVC = .loadSB(SB: .ReturnedItem)
            
            if let _timeData = returnedItemTimeDataManager.getTimeDataItemDefault() {
                vc.selectedTimeData = _timeData
            } else {
                vc.selectedTimeData = returnedItemTimeDataManager.getTimeDataItemType(type: .TimeItemTypeToday)
                returnedItemTimeDataManager.setTimeDataItemDefault(item: vc.selectedTimeData!)
            }
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

