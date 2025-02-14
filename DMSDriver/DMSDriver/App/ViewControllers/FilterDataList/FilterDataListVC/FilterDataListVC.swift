//
//  FilterDataListVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 2/19/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

enum FilterSceneType {
    case RouteListVC
    case RentingOrderListVC
    case PurchaseOrderListVC
}

enum FilterDataListSection:Int {
    case SectionDate = 0
    case SectionType
    case SectionStatus
    case SectionCustomer
    case SectionCity
    
    static let count: Int = {
        var max: Int = 0
        while let _ = FilterDataListSection(rawValue: max) { max += 1 }
        return max
    }()
}

typealias FilterDataListCallback = (Bool, FilterDataModel)-> Void

class FilterDataListVC: BaseViewController {
    
    //MARK: - IBOUTLET
    @IBOutlet weak var btnClearAll:UIButton?
    @IBOutlet weak var btnCancel:UIButton?
    @IBOutlet weak var lblFilterBy:UILabel?
    @IBOutlet weak var tbvContent:UITableView?
    
    
    //MARK: - VARIABLE
    fileprivate let identifierHeaderCell = "identifierHeaderCell"
    fileprivate let identifierTypeRowCell = "identifierTypeRowCell"
    fileprivate let identifierStatusCell = "identifierStatusCell"
    fileprivate let identifierHeaderInsertCell = "identifierHeaderInsertCell"
    fileprivate let identifierInsertRowCell = "FilterDataListInsertRowCell"


    fileprivate var callback:FilterDataListCallback?
    fileprivate var filterModel = FilterDataModel()
    fileprivate var arrRouteStatus:[Status] = []
    fileprivate var arrRentingOrderStatus:[RentingOrderStatus] = []
    fileprivate var arrPurchaseOrderStatus:[PurchaseOrderStatus] = []
    fileprivate var arrCustomer:[String] = []
    fileprivate var arrCity:[String] = []
    fileprivate var arrCustomerDisplay:[String] = []
    fileprivate var arrCityDisplay:[String] = []
    fileprivate let PICKUP_TYPE = "Pickup"
    fileprivate let DELIVERY_TYPE = "Delivery"
    var dataManager = TimeData()
    var isSelected:Bool = false
    var filterSceneType:FilterSceneType = .RouteListVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVar()
        setupTableView()
        setupData()
        App().statusBarView?.backgroundColor = UIColor(hex: 0x2A2E43)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        App().statusBarView?.backgroundColor = UIColor.white
    }
    
    private func initVar()  {
        if let _timeData = dataManager.getTimeDataItemDefault() {
            filterModel.timeData = _timeData
        }else {
            guard let timeDataType = filterModel.timeData?.type else {
                return
            }
            let timeData = dataManager.getTimeDataItemType(type: timeDataType)
            filterModel.timeData = timeData
            dataManager.setTimeDataItemDefault(item: filterModel.timeData!)
        }
    }
    
    func setupData()  {
        
        setupStatusData()
        
        arrCustomer = []
        
        arrCity = []
        
        arrCityDisplay = arrCity
        arrCustomerDisplay = arrCustomer
    }
    
    private func setupStatusData() {
        switch filterSceneType {
        case .RouteListVC:
            setupRouteStatus()
            break
        case .RentingOrderListVC:
            setupRentingOrderStatus()
            break
        case .PurchaseOrderListVC:
            setupPurchaseOrderStatus()
        }
    }
    
    private func setupRouteStatus() {
        let allStatuses = Status()
        allStatuses.name = "all-statuses".localized
        arrRouteStatus.append(allStatuses)
        if CoreDataManager.getListRouteStatus().count == 0 {
            self.getListRouteStatus()
        }
        let routeStatuses = CoreDataManager.getListRouteStatus()
        let routeStatusWithoutDraft = routeStatuses.filter({$0.code != "DR"})
        arrRouteStatus.append(routeStatusWithoutDraft)
    }
    
    private func setupRentingOrderStatus() {
        let allStatuses = RentingOrderStatus()
        allStatuses.name = "all-statuses".localized
        arrRentingOrderStatus.append(allStatuses)
        if CoreDataManager.getListRentingOrderStatus().count == 0 {
//            self.getListRentingOrderStatus()
        }
        arrRentingOrderStatus.append(CoreDataManager.getListRentingOrderStatus())
    }
    
    private func setupPurchaseOrderStatus() {
        let allStatuses = PurchaseOrderStatus()
        allStatuses.name = "all-statuses".localized
        arrPurchaseOrderStatus.append(allStatuses)
        if CoreDataManager.getListPurchaseOrderStatus().count == 0 {
            self.getListPurchaseOrderStatus()
        }
        arrPurchaseOrderStatus.append(CoreDataManager.getListPurchaseOrderStatus())
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setupTableView() {
        tbvContent?.register(UINib(nibName: ClassName(FilterDataListHeaderCell()), bundle: nil), forHeaderFooterViewReuseIdentifier: identifierHeaderCell)
        tbvContent?.register(UINib(nibName: ClassName(FilterDataListHeaderInsertCell()), bundle: nil), forHeaderFooterViewReuseIdentifier: identifierHeaderInsertCell)
        tbvContent?.register(UINib(nibName: ClassName(FilterDataTypeRowCell()), bundle: nil),
                             forCellReuseIdentifier: identifierTypeRowCell)
        tbvContent?.register(UINib(nibName: ClassName(FilterDataListStatusCell()), bundle: nil),
                             forCellReuseIdentifier:identifierStatusCell)
        tbvContent?.register(UINib(nibName: ClassName(FilterDataListInsertRowCell()), bundle: nil),
                             forCellReuseIdentifier: identifierInsertRowCell)
        
        tbvContent?.delegate = self
        tbvContent?.dataSource = self
    }
    
    //MARK: - ACTION
    @IBAction func onbtnClickClearAll(btn:UIButton) {
        filterModel = FilterDataModel()
        tbvContent?.reloadData()
    }
    
    @IBAction func onbtnClickCancel(btn:UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
}


//MARK: - UITableView
extension FilterDataListVC :UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return FilterDataListSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionDisplay = FilterDataListSection(rawValue: section) {
            switch sectionDisplay {
            case .SectionDate:
                return 0
            case .SectionType:
                if filterModel.selectingField == FilterDataModel.SelectingField.TypeField {
                    return 1
                }
            case .SectionStatus:
                if filterModel.selectingField == FilterDataModel.SelectingField.StatusField {
                    switch filterSceneType {
                    case .RouteListVC:
                        return arrRouteStatus.count
                    case .RentingOrderListVC:
                        return arrRentingOrderStatus.count
                    case .PurchaseOrderListVC:
                        return arrPurchaseOrderStatus.count
                    }
                }
            case .SectionCustomer:
                if filterModel.selectingField == FilterDataModel.SelectingField.CustomerField {
                    return 1
                }
                
            case .SectionCity:
                if filterModel.selectingField == FilterDataModel.SelectingField.CityField {
                    return 1
                }
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let sectionDisplay = FilterDataListSection(rawValue: indexPath.section) {
            switch sectionDisplay {
            case .SectionCustomer,
                 .SectionCity:
                return 145 * Constants.SCALE_VALUE_WIDTH_DEVICE
            default:
                break
            }
        }
        return 40 * Constants.SCALE_VALUE_WIDTH_DEVICE
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard  let sectionDisplay = FilterDataListSection(rawValue: section)  else {
            return 0
        }
        switch sectionDisplay {
        case .SectionCustomer,
             .SectionCity, .SectionType:
            return 0 // Currently do not use filter with Customer and City
        default:
            return 60 * Constants.SCALE_VALUE_WIDTH_DEVICE
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sectionDisplay = FilterDataListSection(rawValue: section) {
            switch sectionDisplay {
            case .SectionDate:
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifierHeaderCell) as! FilterDataListHeaderCell
                header.imvIcon?.isHidden = true
                header.delegate = self
                header.tag = section

                if filterModel.timeData == nil {
                    header.lblTitle?.text = "Date".localized.uppercased()
                    header.lblTitle?.textColor = AppColor.white
                }else{
                    if filterModel.timeData?.type == TimeItemType.TimeItemTypeCustom {
                        header.lblTitle?.text = "Date".localized.uppercased() + ": \(E(filterModel.timeData?.subtitle))"
                    }
                    else{
                        header.lblTitle?.text = "Date".localized.uppercased() + ": \(E(filterModel.timeData?.title))"
                    }
                    
                    header.lblTitle?.textColor = AppColor.mainColor
                }
                
                return header
                
            case .SectionType:
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifierHeaderCell) as! FilterDataListHeaderCell
                header.imvIcon?.isHidden = true
                header.delegate = self
                header.tag = section
                if filterModel.type == nil {
                    header.lblTitle?.text = "Type".localized.uppercased()
                    header.lblTitle?.textColor = AppColor.white
                }
                else {
                    var types = filterModel.type?.first
                    if filterModel.type?.count > 1 {
                        types = E(types) + "," + E(filterModel.type?.last)
                    }
                    header.lblTitle?.textColor = AppColor.mainColor
                    header.lblTitle?.text = "Type".localized.uppercased() + ": " + E(types)
                }
                return header
                
            case .SectionStatus:
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifierHeaderCell) as! FilterDataListHeaderCell
                header.imvIcon?.isHidden = true
                header.delegate = self
                header.tag = section
                
                if filterModel.status == nil {
                    header.lblTitle?.text = "Status".localized.uppercased()
                    header.lblTitle?.textColor = AppColor.white
                    
                }else {
                    header.lblTitle?.textColor = AppColor.mainColor
                    header.lblTitle?.text = "Status".localized.uppercased() + ": " + E(filterModel.status?.name?.localized)
                }
                return header

            case .SectionCustomer:
                if filterModel.selectingField == FilterDataModel.SelectingField.CustomerField {
                    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifierHeaderInsertCell) as! FilterDataListHeaderInsertCell
                    header.imvIcon?.isHidden = false
                    header.setPlaceholder("insert-customer-name".localized)
                    header.tag = section
                    header.tfContent?.delegate = self
                    header.tfContent?.tag = 99

                    return header

                }else {
                    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifierHeaderCell) as! FilterDataListHeaderCell
                    header.imvIcon?.isHidden = false
                    header.delegate = self
                    header.tag = section
                    
                    if filterModel.customer == nil {
                        header.lblTitle?.text = "customer".localized.uppercased()
                        header.lblTitle?.textColor = AppColor.white
                    }else {
                        header.lblTitle?.text = "customer".localized.uppercased() + ": " + E(filterModel.customer)
                        header.lblTitle?.textColor = AppColor.mainColor
                    }

                    return header
                }
                
            case .SectionCity:
                if filterModel.selectingField == FilterDataModel.SelectingField.CityField {
                    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifierHeaderInsertCell) as! FilterDataListHeaderInsertCell
                    header.imvIcon?.isHidden = false
                    header.setPlaceholder("insert-city".localized)
                    header.tag = section
                    header.tfContent?.delegate = self
                    header.tfContent?.tag = 100
                    return header
                    
                }else {
                    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifierHeaderCell) as! FilterDataListHeaderCell
                    header.imvIcon?.isHidden = false
                    header.delegate = self
                    header.tag = section
                    if filterModel.city == nil {
                        header.lblTitle?.text = "city".localized.uppercased()
                        header.lblTitle?.textColor = AppColor.white
                    }else {
                        header.lblTitle?.text = "city".localized.uppercased() + ": " + E(filterModel.city)
                        header.lblTitle?.textColor = AppColor.mainColor
                    }
                    
                    return header
                }
            }
        }
        
        return UIView()
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let sectionDisplay = FilterDataListSection(rawValue: section) {
            switch sectionDisplay {
            case .SectionCity:
                return 95 * Constants.SCALE_VALUE_WIDTH_DEVICE
            default:
                break
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let sectionDisplay = FilterDataListSection(rawValue: section) {
            switch sectionDisplay {
            case .SectionCity:
                let footerView:FilterDataListFooterView = FilterDataListFooterView.load(nib: ClassName(FilterDataListFooterView()), owner: nil)
                footerView.delegate = self
                return footerView
            default:
                break
            }
        }
    
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        if let sectionDisplay = FilterDataListSection(rawValue: section) {
            switch sectionDisplay {
            case .SectionDate:
                break
            case .SectionType:
                let cell = tableView.dequeueReusableCell(withIdentifier: identifierTypeRowCell) as! FilterDataTypeRowCell
                cell.delegate = self
                cell.selectionStyle = .none
                cell.btnPickup?.backgroundColor = UIColor.gray
                cell.btnDelivery?.backgroundColor = UIColor.gray

                let arrType = filterModel.type ?? []
                if arrType.contains(PICKUP_TYPE) {
                    cell.btnPickup?.backgroundColor = AppColor.buttonColor
                }
                
                if arrType.contains(DELIVERY_TYPE){
                    cell.btnDelivery?.backgroundColor = AppColor.buttonColor
                }
                
                return cell
                
            case .SectionStatus:
                let cell = tableView.dequeueReusableCell(withIdentifier: identifierStatusCell) as! FilterDataListStatusCell
                var arrStatus:[BasicModel] = []
                switch filterSceneType {
                case .RouteListVC:
                    arrStatus = arrRouteStatus
                    break
                case .RentingOrderListVC:
                    arrStatus = arrRentingOrderStatus
                    break
                case .PurchaseOrderListVC:
                    arrStatus = arrPurchaseOrderStatus
                }
                cell.btnStatus?.setTitle(arrStatus[row].name, for: .normal)
                cell.btnStatus?.tag = indexPath.row
                cell.delegate = self
                cell.selectionStyle = .none
                cell.btnStatus?.backgroundColor = UIColor.gray
                if filterModel.status?.id == arrStatus[row].id {
                    cell.btnStatus?.backgroundColor = AppColor.buttonColor
                }

                return cell
                
            case .SectionCustomer:
                let cell = tableView.dequeueReusableCell(withIdentifier:identifierInsertRowCell ) as! FilterDataListInsertRowCell
                cell.dataSource = arrCustomerDisplay
                cell.selectionStyle = .none
                cell.delegate = self

                return cell
                
            case .SectionCity:
                let cell = tableView.dequeueReusableCell(withIdentifier: identifierInsertRowCell) as! FilterDataListInsertRowCell
                cell.dataSource = arrCityDisplay
                cell.selectionStyle = .none
                cell.delegate = self

                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
}

//MARK: - FilterDataListFooterViewDelegate
extension FilterDataListVC:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            print("text:\(text)")
            let searchText = text.replacingCharacters(in: textRange,
                                                       with: string)
            
            if textField.tag == 99 { // Customer
                
                doSearchCustomer(searchText: searchText)
                
            }else if textField.tag == 100 {// City
                
                doSearchCity(searchText: searchText)
            }
        }
        return true
    }
    
    func doSearchCustomer(searchText:String){
        let newSearchString = searchText.components(separatedBy: "\n").first?.lowercased()
        if !isEmpty(newSearchString) {
            arrCustomerDisplay = arrCustomer.filter({ (item) -> Bool in
                let isExist = item.lowercased().contains(newSearchString!)
                return isExist
            })
            
        }else {
            arrCustomerDisplay = arrCustomer
        }
        tbvContent?.reloadData()
    }
    
    
    func doSearchCity(searchText:String){
        let newSearchString = searchText.components(separatedBy: "\n").first?.lowercased()
        if !isEmpty(newSearchString) {
            arrCityDisplay = arrCity.filter({ (item) -> Bool in
                let isExist = item.lowercased().contains(newSearchString!)
                return isExist
            })
            
        }else {
            arrCityDisplay = arrCity
        }
        
        tbvContent?.reloadData()
    }
}

//MARK: - FilterDataListInsertRowCellDelegate
extension FilterDataListVC:FilterDataListInsertRowCellDelegate {
    func filterDataListInsertRowCell(cell: FilterDataListInsertRowCell, didSelect indexPath: IndexPath) {
        guard let indexPathAtFilterDataList = tbvContent?.indexPath(for: cell) else {
            return
        }
        filterModel.selectingField = nil
        let section = FilterDataListSection(rawValue: indexPathAtFilterDataList.section)
        if section == FilterDataListSection.SectionCustomer {
            
            filterModel.customer = arrCustomerDisplay[indexPath.row]
            
        }else if (section == FilterDataListSection.SectionCity) {
            
            filterModel.city = arrCityDisplay[indexPath.row]
        }
        
        tbvContent?.reloadData()
    }
}

//MARK: - FilterDataListFooterViewDelegate
extension FilterDataListVC:FilterDataTypeRowCellDelegate {
    func filterDataTypeRowCell(cell: FilterDataTypeRowCell, didSelectType type: String) {
        filterModel.selectingField = nil
        if filterModel.type == nil {
            filterModel.type = []
            filterModel.type?.append(type)
            
        }else {
            if !(filterModel.type?.contains(type) ?? false) {
                filterModel.type?.append(type)
            }
        }
        tbvContent?.reloadData()
    }
}


//MARK: - FilterDataListStatusCellDelegate
extension FilterDataListVC:FilterDataListStatusCellDelegate{
    func filterDataListStatusCell(cell: FilterDataListStatusCell, didSelect status: String, index: Int) {
        isSelected = false
        var status = BasicModel()
        switch filterSceneType {
        case .RouteListVC:
            status = arrRouteStatus[index]
        case .RentingOrderListVC:
            status = arrRentingOrderStatus[index]
        case .PurchaseOrderListVC:
            status = arrPurchaseOrderStatus[index]
        }
        filterModel.status = status
        filterModel.selectingField = nil
        tbvContent?.reloadData()
    }
}


//MARK: - FilterDataListFooterViewDelegate
extension FilterDataListVC:FilterDataListFooterViewDelegate {
    func filterDataListFooterView(view: FilterDataListFooterView, didSelectSearch: UIButton) {
        self.dismiss(animated: false) {[weak self] in
            guard let strongSelf =   self else {return}
            print("FilterModel: \(strongSelf.filterModel)")
            strongSelf.callback?(true,strongSelf.filterModel)
        }
    }
}


//MARK: - FilterDataListHeaderCellDelegate
extension FilterDataListVC:FilterDataListHeaderCellDelegate{
    func filterDataListHeaderCell(cell: FilterDataListHeaderCell, didSelectHeader btn: UIButton) {
        let section = cell.tag
        filterModel.selectingField = FilterDataModel.SelectingField(rawValue: section)
        guard let sectionDisplay = FilterDataListSection(rawValue: section) else {
            return
        }
        switch sectionDisplay {
        case .SectionDate:
            doPickdate(btn: btn)
        case .SectionType:
            break
        case .SectionStatus:
            break
        case .SectionCustomer:
            break
        case .SectionCity:
            break

        }
        
        if !isSelected {
            isSelected = true
            let transition = CATransition()
            transition.type = CATransitionType.moveIn
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.fillMode = CAMediaTimingFillMode.forwards
            transition.duration = 0.5
            transition.subtype = CATransitionSubtype.fromTop
            self.tbvContent?.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
            
        }
        self.tbvContent?.reloadData()
        if sectionDisplay == .SectionCity {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tbvContent?.selectRow(at: IndexPath(row: 0, section: FilterDataListSection.SectionCity.rawValue), animated: true, scrollPosition: .bottom)
            }
        }

        
        /*
        UIView.transition(with: tbvContent!,
                          duration: 0.35,
                          options: .curveEaseInOut,
                          animations: {
                            self.tbvContent?.reloadData()
        }, completion: nil)
       */
    }
    
    func doPickdate(btn:UIButton) {
        let arrHide = [TimeItemType.TimeItemTypeLastYear.rawValue,
                       TimeItemType.TimeItemTypeThisYear.rawValue,
                       TimeItemType.TimeItemTypeNextYear.rawValue]
        FilterByDatePopupView.showFilterListTimeAtView(view: btn,
                                                       atViewContrller: self,
                                                       timeData: filterModel.timeData,
                                                       needHides: arrHide as [NSNumber]) {[weak self] (success, timeData) in
                                                        self?.filterModel.timeData = timeData
                                                        self?.tbvContent?.reloadData()
        }
        isSelected = false
    }
}

//MARK: - Suport method
extension FilterDataListVC {
    
    private func getListRouteStatus() {
        SERVICES().API.getListRouteStatus { (result) in
            switch result{
            case .object(let obj):
                guard let list = obj.data?.data else {return}
                CoreDataManager.updateRouteListStatus(list)
            case .error(_ ):
                break
            }
        }
    }
    
    private func getListRentingOrderStatus() {
        SERVICES().API.getListRentingOrderStatus { (result) in
            switch result{
            case .object(let obj):
                guard let list = obj.data else {return}
                CoreDataManager.updateRentingOrderStatus(list)
            case .error(_ ):
                break
            }
        }
    }
    
    private func getListPurchaseOrderStatus() {
        SERVICES().API.getListPurchaseOrderStatus { (result) in
            switch result{
            case .object(let obj):
                guard let list = obj.data else {return}
                CoreDataManager.updatePurchaseOrderStatus(list)
            case .error(_ ):
                break
            }
        }
    }
    
    class func show(atViewController viewController:UIViewController,
                    currentFilter:FilterDataModel?, filterScenceType:FilterSceneType = .RouteListVC,
                    callback:@escaping FilterDataListCallback)  {
        let vc:FilterDataListVC = FilterDataListVC.load(nib: "FilterDataListVC")
        vc.callback = callback
        vc.filterSceneType = filterScenceType
        if let copyObject:FilterDataModel = currentFilter?.cloneObject(){
            vc.filterModel = copyObject
        }
        
        let nv:BaseNV = BaseNV()
        nv.isNavigationBarHidden = true
        nv.setViewControllers([vc], animated: false)
        viewController.present(nv, animated: false, completion: nil)
    }
}
