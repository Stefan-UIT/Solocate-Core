
import UIKit

enum MenuItemType : Int {
  
  case PROFILE = 0
  case DASHBOARD
  case ROUTES
  case COUNTER
  case RENTINGORDERS
  case TASK
    case RETURNEDITEMS
    case PURCHASEORDER
    case BUSINESSORDER
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
    case .PURCHASEORDER:
        return "purchase-order".localized.uppercased()
    case .BUSINESSORDER:
        return "business-order".localized.uppercased()
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
    case .PURCHASEORDER:
        return #imageLiteral(resourceName: "ic_orderlist")
    case .BUSINESSORDER:
        return #imageLiteral(resourceName: "ic_orderlist")
    }
  }
}


class SlideMenuVC: BaseViewController {
  
    @IBOutlet weak var buildVersionLabel: UILabel!
    @IBOutlet weak var tbvContent:UITableView?

    fileprivate let profileIndentifierCell = "SlideMenuAvartarCell"
    fileprivate let rowIndentifierCell = "SlideMenuRowCell"
    private let CELL_HEIGHT:CGFloat = 100

    var currentItem:MenuItemType = .ROUTES
    var returnedItemTimeDataManager = TimeData()
    var purchaseOrderTimeDataManager = TimeData()
    var businessOrderTimeDataManager = TimeData()
    var taskTimeDataManager = TimeData()
    var previousItem:Int = MenuItemType.DASHBOARD.rawValue
    
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
        if menutype == .RENTINGORDERS || menutype == .DASHBOARD || menutype == .COUNTER || menutype == .ALERT || menutype == .RETURNEDITEMS || menutype == .TASK || menutype == .PURCHASEORDER {
            return 0
        }
    }
    
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return CELL_HEIGHT
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
    
    if menuType != MenuItemType.LOGOUT {
        previousItem = indexPath.row
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
            let alert = UIAlertController(title: "are-you-sure-you-want-to-logout".localized, message: "", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.default, handler: { action in
                self.currentItem = MenuItemType.init(rawValue: self.previousItem)!
                self.tbvContent?.reloadData()
            }))
            
            alert.addAction(UIAlertAction(title: "ok".localized, style: UIAlertAction.Style.default, handler: { action in
                DispatchQueue.main.async {
                    self.navigationController?.dismiss(animated: false, completion: {
                        self.handleLogOut()
                    })
                }
            }))
            self.present(alert, animated: true, completion: nil)
            
        case .PURCHASEORDER:
            let vc:PurchaseOrderListVC = .loadSB(SB: .PurchaseOrder)
            
            if let _timeData = purchaseOrderTimeDataManager.getTimeDataItemDefault() {
                vc.selectedTimeData = _timeData
            } else {
                vc.selectedTimeData = purchaseOrderTimeDataManager.getTimeDataItemType(type: .TimeItemTypeToday)
                purchaseOrderTimeDataManager.setTimeDataItemDefault(item: vc.selectedTimeData!)
            }
            App().mainVC?.rootNV?.setViewControllers([vc], animated: false)
        case .BUSINESSORDER:
            let vc:BusinessOrderListVC = .loadSB(SB: .BusinessOrder)
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

//MARK: API
private extension SlideMenuVC{
    func handleLogOut() {
        CoreDataManager.clearAllDB()
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
