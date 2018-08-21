//
//  AssignOrderVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 8/15/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import SideMenu


class AssignOrderVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noOrdersLabel: UILabel?
    @IBOutlet weak var conWidthDateFlter: NSLayoutConstraint?
    @IBOutlet weak var viewDateFlter: UIView?
    @IBOutlet weak var tfSearch: UITextField?
    @IBOutlet weak var lblShowDateFilter: UILabel?
    @IBOutlet weak var viewFilter: UIView?




    fileprivate let cellIdentifier = "OrderItemTableViewCell"
    fileprivate let cellHeight: CGFloat = 150.0
    fileprivate var orderList:[Order] = []
    fileprivate var dataDisplay:[Order] = []
    fileprivate var stringSearch = ""
    fileprivate var dateStringFilter:String = Date().toString("yyyy-MM-dd")
    fileprivate var dateFilter = Date()

    
    fileprivate var isSelectAssign = false{
        didSet{
            self.tableView.reloadData()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getListOrderAssign()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func updateNavigationBar() {
        self.navigationService.delegate = self
        self.navigationService.updateNavigationBar(.Menu_Select, "Orders assignment".localized)
    }
    
    func updateUI() {
        setupTableView()
        setupTextFieldSearch()
        noOrdersLabel?.isHidden = orderList.count > 0
        lblShowDateFilter?.text = "Today".localized
        viewFilter?.setShadowDefault()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addRefreshControl(self, action: #selector(fetchData))
    }
    
    func setupTextFieldSearch() {
        tfSearch?.delegate = self
    }
    
    // MARK: - Action
    @IBAction func onbtnClickFilterDate(btn:UIButton){
        UIAlertController.showDatePicker(style: .actionSheet,
                                         mode: .date,
                                         title: "Select date".localized,
                                         currentDate: nil) {[weak self] (date) in
            self?.dateFilter = date
            self?.dateStringFilter = date.toString("yyyy-MM-dd")
            self?.lblShowDateFilter?.text = self?.dateStringFilter
            self?.getListOrderAssign()
                                            
        }
    }

}

// MARK: - Private methods

extension AssignOrderVC {
    func convertString(_ text: String, withFormat format: String = "yyyy-MM-dd") -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let date = dateFormater.date(from: text) ?? Date()
        dateFormater.dateFormat = format
        
        return dateFormater.string(from: date)
    }
}


//MARK: - UITableViewDelegate,UITableViewDataSource
extension AssignOrderVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataDisplay.count
    }
    
    
    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AssignOrderCell {
            
            let order = dataDisplay[indexPath.row]
            cell.isSelectAssign = isSelectAssign
            cell.order = order
            cell.btnNumber?.setTitle("\(indexPath.row + 1)", for: .normal)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        if isSelectAssign {
            dataDisplay[row].isSelect = !dataDisplay[row].isSelect
            self.tableView.reloadData()
            
        }else{
            let vc:OrderDetailContainerViewController = .loadSB(SB: .Order)
            vc.onUpdateOrderStatus = {(order)  in
                //
            }
            
            let order = dataDisplay[row]
            vc.order = order
            vc.routeID = order.routeId
            vc.dateStringFilter = dateStringFilter
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension AssignOrderVC:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        if Constants.isLeftToRight {
            present(SideMenuManager.default.menuLeftNavigationController!,
                    animated: true,completion: nil)
        }else{
            present(SideMenuManager.default.menuRightNavigationController!,
                    animated: true,completion: nil)
        }
    }
    
    func didSelectedRightButton() {
        isSelectAssign = true
        self.navigationService.updateNavigationBar(.CancelAssign, "Select Items".localized)
        showFilterDate(false)
   
    }
    
    func didSelectedCancelButton(_ sender: UIBarButtonItem) {
        isSelectAssign = false
        self.navigationService.updateNavigationBar(.Menu_Select, "Assign".localized)
        showFilterDate(true)
       
    }
    
    func showFilterDate(_ isShow:Bool)  {
        if isShow {
            conWidthDateFlter?.constant = 110
            UIView.animate(withDuration: 0.25) {
                self.viewDateFlter?.alpha = 1
                self.view.layoutIfNeeded()
            }
        }else{
            conWidthDateFlter?.constant = 0
            UIView.animate(withDuration: 0.25) {
                self.viewDateFlter?.alpha = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func didSelectedAssignButton(_ sender: UIBarButtonItem) {
        let requestAssignOrder = RequestAssignOrderModel()
        requestAssignOrder.date = dateStringFilter
        let arrSelect = dataDisplay.filter { (item) -> Bool in
            if item.isSelect {
                requestAssignOrder.order_ids.append("\(item.id)")
            }
            
            return item.isSelect
        }
        if arrSelect.count == 0 {
            self.showAlertView("Please select order.".localized)
            
        }else {
            PickerTypeListVC.showPickerTypeList(pickerType: .DriverSignlePick) {[weak self] (success, data) in
                if success{
                    if let drivers = data as? [DriverModel]{
                        requestAssignOrder.driver_id = drivers.first?.driver_id
                        self?.assignOrderToDriver(requestAssignOrder)
                    }
                }
            }
        }
    }
}

extension AssignOrderVC:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            print("search text:\(updatedText)")
            stringSearch = updatedText
            doSearch(strSearch: stringSearch)
    
        }
        return true
    }
    
    func doSearch(strSearch:String? = nil)  {
        let newSearchString = strSearch?.components(separatedBy: "\n").first?.lowercased()
        if !isEmpty(newSearchString) {
            dataDisplay = orderList.filter({ (item) -> Bool in
                let isExist = item.driver_name.lowercased().contains(newSearchString!) ||
                              item.orderReference.lowercased().contains(newSearchString!)
                return isExist
            })
        }else {
            dataDisplay = orderList
        }
        self.noOrdersLabel?.isHidden = dataDisplay.count > 0
        self.tableView?.reloadData()
    }
}


//MARK: - API
extension AssignOrderVC{
    
    @objc func fetchData()  {
        getListOrderAssign(isFetch: true)
    }
    
    func getListOrderAssign(isFetch:Bool = false) {
        if !isFetch {
            self.showLoadingIndicator()
        }
        API().getOrderByCoordinator(byDate: dateStringFilter) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.tableView.endRefreshControl()
            switch result{
            case .object(let obj):
                guard let data = obj.data else{return}
                self?.orderList = data
                self?.doSearch(strSearch: self?.stringSearch)
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    func assignOrderToDriver(_ requestAssignOrder:RequestAssignOrderModel)  {
        self.showLoadingIndicator()
        API().assignOrderToDriver(body: requestAssignOrder) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.fetchData()
                self?.isSelectAssign = false
                self?.updateNavigationBar()
                self?.showFilterDate(true)
                self?.showAlertView("Assigned successfull.".localized)
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}

