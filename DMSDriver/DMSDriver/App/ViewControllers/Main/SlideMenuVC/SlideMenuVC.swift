
import UIKit

enum MenuItemType : Int {
  
  case PROFILE = 0
  case ROUTES = 1
  case LOGOUT = 2
  
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
          App().mainVC?.rootNV?.pushViewController(vc, animated: false)
          break
        case .ROUTES:
          App().mainVC?.pushRouteListVC()
          break
        case .LOGOUT:
          self.handleLogOut()
          break
        }
      }
      
      DispatchQueue.main.async {
        self.navigationController?.dismiss(animated: true, completion: nil)
      }
    }
  }
}

//MARK: API
private extension SlideMenuVC{
  func handleLogOut() {
    API().logout { (result) in
      switch result{
      case .object(_):
        break
      case .error(let error):
        self.showAlertView(error.getMessage())
      }
    }
    App().reLogin()
  }
}

