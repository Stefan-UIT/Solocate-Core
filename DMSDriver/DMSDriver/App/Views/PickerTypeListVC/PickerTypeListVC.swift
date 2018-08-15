
import UIKit


typealias PickerTypeListCallBack = (_ success:Bool,_ data:[SelectionModel]) -> Void

class PickerTypeListVC: BaseViewController {
    
    enum PickerTypeList {
        case DriverSignlePick
        case DriverMultiplePick
    }
    
    
    @IBOutlet weak var tbvContent:UITableView?
    @IBOutlet weak var lblNodata:UILabel?

    
    fileprivate var callback:PickerTypeListCallBack?
    
    fileprivate var titleHeader:String = "Driver"
    fileprivate var type:PickerTypeList = .DriverSignlePick
    
    fileprivate var dataDisplays:[SelectionModel] = []
    fileprivate var dataOrigins:[SelectionModel] = []
    
    fileprivate var arrOldData:[SelectionModel] = []

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        fetchData()
    }
    
    override func updateNavigationBar() {
        self.navigationService.updateNavigationBar(.BackDone, titleHeader)
        self.navigationService.delegate = self
    }

    
    func setupTableView() {
        tbvContent?.delegate = self
        tbvContent?.dataSource = self
        tbvContent?.addRefreshControl(self, action: #selector(fetchData))
    }
    
    func updateUI()  {
        setupTableView()
        setupTitleHeader()
    }
    
    func setupTitleHeader()  {
        switch type {
        case .DriverSignlePick,
             .DriverMultiplePick:
            titleHeader = "Pick driver"
        }
    }
    
    @objc func fetchData()  {
        switch type {
        case .DriverMultiplePick,
             .DriverSignlePick:
            getListDriver()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - Helper funtion
extension PickerTypeListVC{
    
    class func showPickerTypeList(pickerType:PickerTypeList,
                                  oldData:[SelectionModel]? = nil,
                                 callback: @escaping PickerTypeListCallBack)  {
        
        let vc:PickerTypeListVC = .loadSB(SB: .Common)
        vc.type = pickerType
        vc.setCallback(callback: callback)
        if let old = oldData {
            vc.arrOldData = old
        }
        App().mainVC?.rootNV?.pushViewController(vc, animated: true)
    }
    
    func setCallback(callback:@escaping PickerTypeListCallBack)  {
        self.callback = callback
    }
}


//MARK: - UITableViewDelegate
extension PickerTypeListVC:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataDisplays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell:PickerTypeListCell = tableView.dequeueReusableCell(withIdentifier: "PickerTypeListCell", for: indexPath) as! PickerTypeListCell
        
        switch type {
        case .DriverMultiplePick,
             .DriverSignlePick:
            
            if let dto:DriverModel = dataDisplays[row] as? DriverModel{
                cell.lblTitle?.text = dto.driver_name
                cell.lblSubtitle?.text = dto.role_name
                cell.imgIcon?.image = dto.isSelected ? #imageLiteral(resourceName: "ic_selected") : #imageLiteral(resourceName: "ic_nonselected")
            }
        }
        
        return cell
    }

}


//MARK: - UITableViewDelegate
extension PickerTypeListVC:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch type {
        case .DriverSignlePick:
            for item in dataDisplays{
                item.isSelected = false
            }
            dataDisplays[indexPath.row].isSelected = true
            
        case .DriverMultiplePick:
            
              dataDisplays[indexPath.row].isSelected = !dataDisplays[indexPath.row].isSelected
        }
        
        tbvContent?.reloadData()
    }
}

extension PickerTypeListVC:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didSelectedRightButton() {
        var data:[SelectionModel] = []
        for item in dataDisplays {
            if item.isSelected {
                data.append(item)
            }
        }
        
        callback?(true,data)
        self.navigationController?.popViewController(animated: true)
    }
}


//MARK: - CALL API
fileprivate extension PickerTypeListVC{
    func getListDriver()  {
        self.showLoadingIndicator()
        API().getDriversByCoordinator {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.tbvContent?.endRefreshControl()
            switch result{
            case .object(let obj):
                self?.dataOrigins = obj.data ?? []
                self?.dataDisplays = obj.data ?? []
                self?.lblNodata?.isHidden = self?.dataDisplays.count > 0
                self?.checkOldData()
                self?.tbvContent?.reloadData()
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    
    func checkOldData()  {
        for old in arrOldData {
            for item in dataDisplays {
                if old.strId == item.strId{
                    item.isSelected = true
                    break
                }
            }
        }
    }
}



