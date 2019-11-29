//
//  LoadUnloadOrderVC.swift
//  DMSDriver
//
//  Created by Apple on 5/16/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

typealias LoadUnloadOrderVCCallback = (Bool,Order?) -> Void

class LoadUnloadOrderVC: BaseViewController {
    
    @IBOutlet weak var tbvContent:UITableView?
    @IBOutlet weak var searchView:BaseSearchView?
    @IBOutlet weak var lblNoResult:UILabel?
    
    private var strSearch:String?
    private let cellContentIdentifier = "LoadUnLoadListCell"
    private let loadPackageCellIdentifier = "LoadPackageTableViewCell"
    private let loadSKUIdentifier = "LoadOrderDetailSKUCell"
    private let CELL_HEIGHT:CGFloat = 100.0
    private var dataOrigin:[Order.Detail] = []
    private var dataDisplay:[Order.Detail] = []
    private var dataOrderDisplay:[Order] = []

    var callback:LoadUnloadOrderVCCallback?
    var selectedDetail:Order.Detail?
    var selectedOrder:Order? {
        get {
            guard let detail = selectedDetail else { return nil }
            let array = orders.filter({ detail.id == $0.details?.first?.id })
            return array.first
        }
    }
    
    var route:Route!
    var orders:[Order] = []
    var ordersAbleToLoad:[Order] {
        get {
            return orders.filter({$0.statusOrder == StatusOrder.newStatus})
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        App().mainVC?.navigationController?.isNavigationBarHidden = false
    }
    
    deinit {
        App().mainVC?.navigationController?.isNavigationBarHidden = true
    }
    
    override func updateNavigationBar() {
        let routeName = "Route".localized + " #\(route.id)" + " - " + E(route.routeMaster?.name)
        App().navigationService.updateNavigationBar(.BackOnly,
                                                    "packages-list".localized,
                                                    AppColor.white, true, routeName)
        App().navigationService.delegate = self
    }
    
    func orderWithDetail(_ detail:Order.Detail) -> Order? {
        let array = orders.filter({detail.id == $0.details?.first?.id})
        return array.first
    }
    
    func getAllDetailsFromOrders() -> [Order.Detail]{
        var details:[Order.Detail] = []
        for value in ordersAbleToLoad {
            dataOrderDisplay.append(value)
            details.append(value.details ?? [])
        }
        return details
    }
    
    func initData()  {
        dataOrigin = getAllDetailsFromOrders()
        doSearch(strSearch: strSearch)
    }
    
    func initUI() {
        setupTableView()
        setupSearchView()
    }
   
    func setupTableView() {
        tbvContent?.delegate = self
        tbvContent?.dataSource = self
    }
    
    func setupSearchView() {
        searchView?.delegate = self
    }
    
    //MARK : - Action
    @IBAction func onbtnClickScanBarCode(btn:UIButton){
        let vc:ScanBarCodeViewController =  ScanBarCodeViewController.loadSB(SB: .Order)
        vc.didScan = {[weak self](code) in
            self?.strSearch = code
            self?.searchView?.vSearch?.tfSearch?.text = code
            self?.doSearch(strSearch: code)
        }
        
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
}

extension LoadUnloadOrderVC: LoadPackageTableViewCellDelegate {
    func didTouchOnLoadButton(_ cell: LoadPackageTableViewCell, detail: Order.Detail) {
        selectedDetail = detail
        submitLoadedQuantity(detail: detail)
    }
    
}

extension LoadUnloadOrderVC: LoadOrderDetailSKUTableViewCellDelete {
    func didEnterDeliveredQuantityTextField(_ cell: LoadOrderDetailSKUTableViewCell, value: String, detail: Order.Detail) {
        selectedDetail = detail
        submitLoadedQuantity(detail: detail)
    }
}

extension LoadUnloadOrderVC {
    func submitLoadedQuantity(detail:Order.Detail) {
        if let loadedQty = detail.pivot?.loadedQty, let qty = detail.pivot?.qty, loadedQty <= qty {
            updateLoadedQuantity(detail:detail)
            // call without loaded carton
        } else {
            let message = String(format: "loaded-quantity-must-be-less-than-or-equal".localized, "\(detail.pivot?.qty ?? 0)")
            showAlertView(message)
            return
        }
    }
    
    func updateLoadedQuantity(detail:Order.Detail) {
        let status = detail.getLoadedStatusWithLoadingQuantity()
        updateOrderStatus(status.rawValue)
    }
    
    func updateOrderStatus(_ statusCode: String) {
        guard let _orderDetail = selectedOrder else {
            return
        }
        let listStatus =  CoreDataManager.getListStatus()
        for item in listStatus {
            if item.code == statusCode{
                _orderDetail.status = item
                break
            }
        }
        
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        updateOrderStatusImport(_orderDetail)
    }
    
    
    func updateOrderStatusImport(_ order:Order)  {
        SERVICES().API.updateOrderStatus(order, updateDetailType:.Load) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(let obj):
                self?.showAlertView(MSG_UPDATED_SUCCESSFUL)
                self?.initData()
                break
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}

//MARK : - UITableViewDataSource
extension LoadUnloadOrderVC:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataDisplay.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detail = dataDisplay[indexPath.row]
        let order = dataOrderDisplay[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: loadSKUIdentifier, for: indexPath) as! LoadOrderDetailSKUTableViewCell
        cell.configureCell(detail: detail, order: order)
        cell.delegate = self
        return cell
    }
}


//MARK : - UITableViewDelegate
extension LoadUnloadOrderVC:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
}

extension LoadUnloadOrderVC:BaseSearchViewDelegate{
    func tfSearchShouldBeginEditing(view: BaseSearchView, textField: UITextField) {
        //
    }
    
    func tfSearchShouldChangeCharactersInRangeWithString(view: BaseSearchView, text: String) {
        strSearch = text
        self.doSearch(strSearch: strSearch)
    }
    
    func tfSearchDidEndEditing(view: BaseSearchView, textField: UITextField) {
        //
    }
    
    func doSearch(strSearch:String? = nil)  {
        let newSearchString = strSearch?.components(separatedBy: "\n").first?.lowercased()
        if !isEmpty(newSearchString) {
            dataDisplay = dataOrigin.filter({ (item) -> Bool in
                let isExist = item.wmsOrderCode?.lowercased().contains(newSearchString!)
                return isExist ?? false
            })
            
        }else {
            dataDisplay = dataOrigin
        }
        if dataDisplay.count <= 0 {
            UIView.addViewNoItemWithTitle("no-data".localized, intoParentView: self.view)
        }else {
            UIView.removeViewNoItemAtParentView(self.view!)
        }
        self.tbvContent?.reloadData()
    }
}


//MARK : - DMSNavigationServiceDelegate
extension LoadUnloadOrderVC:DMSNavigationServiceDelegate {
    
    func didSelectedBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
}
