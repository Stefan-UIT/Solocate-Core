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
    private var dataOrigin:[Order.Detail] = []
    private var dataDisplay:[Order.Detail] = []

    var callback:LoadUnloadOrderVCCallback?
    
    var selectedDetail:Order.Detail?
    var selectedOrder:Order? {
        get {
            guard let detail = selectedDetail else { return nil }
            let array = orders.filter({ detail.id == $0.details?.first?.id })
            return array.first
        }
    }
    
    var orders:[Order] = []
    var ordersAbleToLoad:[Order] {
        get {
            return orders.filter({$0.statusOrder == StatusOrder.newStatus || $0.statusOrder == StatusOrder.WarehouseClarification})
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
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.BackOnly,
                                                    "packages-list".localized,
                                                    AppColor.white, true)
    }
    
    
    func getAllDetailsFromOrders() -> [Order.Detail]{
        var details:[Order.Detail] = []
        for value in ordersAbleToLoad {
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

extension LoadUnloadOrderVC {
    func submitLoadedQuantity(detail:Order.Detail) {
        if let loadedQty = detail.loadedQty, let qty = detail.qty, loadedQty <= qty {
            if (detail.isPallet) {
                if let loadedCartons = detail.loadedCartonsInPallet {
                    let cartons = detail.cartonsInPallet ?? 0
                    if loadedCartons <= cartons {
                        updateLoadedQuantity(detail:detail)
                        return
                    }
                }
                showAlertView("Loaded cartons must be less than or equal \(detail.cartonsInPallet ?? 0)")
                return
            }
            updateLoadedQuantity(detail:detail)
            // call without loaded carton
        } else {
            showAlertView("Loaded quantity must be less than or equal \(detail.qty ?? 0)")
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
                self?.showAlertView("updated-successful".localized)
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
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detail = dataDisplay[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: loadPackageCellIdentifier, for: indexPath) as! LoadPackageTableViewCell
        
        cell.configureCellWithDetail(detail)
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


//MARK : - LoadUnLoadListCellDelegate
//extension LoadUnloadOrderVC:LoadUnLoadListCellDelegate{
//    func didSelectedLoadUnload(cell: LoadUnLoadListCell, orderDetail: Order.Detail?) {
//        guard let order = selectedOrder,
//              let detail = orderDetail,
//              let indexPath = tbvContent?.indexPath(for: cell) else {
//            return
//        }
//
//        showAlertView("Submit Load")
//        let row = indexPath.row
//        switch detail.status {
//        case .NotLoad:
//            orderDetail?.status = .Loaded
//
//        case .Loaded:
//            if order.statusOrder == .newStatus ||
//                order.statusOrder == .InTransit {
//                detail.status = .NotLoad
//            }else if (order.statusOrder == .PickupStatus) {
//                detail.status = .Unload
//            }
//
//        case .Unload:
//            if order.statusOrder == .PickupStatus {
//                detail.status = .Loaded
//            }
//        }
//
//        for var item in order.details ?? [] {
//            if item.barCode == detail.barCode {
//                item = detail
//                break
//            }
//        }
//
//        dataDisplay[row] = detail
//        tbvContent?.reloadRows(at: [indexPath], with: .automatic)
//
//        if validUpdateStatusOrder() == true {
//            if order.statusOrder == StatusOrder.InTransit {
//                updateStatusOrder(statusCode: StatusOrder.PickupStatus.rawValue)
//
//            }else {
//
//                if order.isRequireSign() == false && order.isRequireImage() == false {
//
//                    updateStatusOrder(statusCode: StatusOrder.deliveryStatus.rawValue)
//
//                }else {
//
//                     if order.isRequireImage(){
//                        self.showAlertView("you-need-add-least-a-picture-to-finish-this-order".localized) {[weak self](action) in
//                            self?.showPictureViewController()
//                        }
//
//                    }else if (order.isRequireSign()) {
//                        self.showAlertView("you-need-add-customer-s-signature-to-finish-this-order".localized) {[weak self](action) in
//                            self?.showSignatureViewController()
//                        }
//
//                     }else {
//
//                        let statusNeedUpdate = StatusOrder.deliveryStatus.rawValue
//                        self.updateStatusOrder(statusCode: statusNeedUpdate)
//                    }
//                }
//            }
//        }
//    }

//    func validUpdateStatusOrder() -> Bool {
//        var valid = true
//        for item in order?.details ?? []  {
//            if order?.statusOrder == StatusOrder.InTransit {
//                if item.status != .Loaded {
//                   valid = false
//                    break
//                }
//            }else if order?.statusOrder == StatusOrder.PickupStatus {
//                if item.status != .Unload {
//                    valid = false
//                    break
//                }
//            }
//        }
//
//        return valid
//    }
    
//    func showPictureViewController() {
//        let viewController = PictureViewController()
//        let navi = BaseNV(rootViewController: viewController)
//        navi.statusBarStyle = .lightContent
//        viewController.order = order
//        viewController.callback = {[weak self](success,order) in
//            if success {
//                self?.callback?(true,order)
//            }
//        }
//        present(navi, animated: true, completion: nil)
//    }
//
//    func showSignatureViewController() {
//        let viewController = SignatureViewController()
//        viewController.delegate = self
//        viewController.order = order
//        self.callback?(true,order)
//        self.navigationController?.present(viewController, animated: true, completion: nil)
//    }
//}
    
//MARK: - BaseSearchViewDelegate



//MARK: - API
//extension LoadUnloadOrderVC {
//    fileprivate func updateStatusOrder(statusCode: String, cancelReason:Reason? = nil) {
//        guard let _orderDetail:Order = selectedOrder?.cloneObject() else {
//            return
//        }
//        let listStatus =  CoreDataManager.getListStatus()
//        for item in listStatus {
//            if item.code == statusCode{
//                _orderDetail.status = item
//                break
//            }
//        }
//
//        if hasNetworkConnection {
//            showLoadingIndicator()
//        }
//
//        SERVICES().API.updateOrderStatus(_orderDetail,reason: cancelReason) {[weak self] (result) in
//            self?.dismissLoadingIndicator()
//            switch result{
//            case .object(_):
//                self?.order = _orderDetail
//                self?.callback?(true,_orderDetail)
//
//                if _orderDetail.statusOrder == StatusOrder.deliveryStatus {
//                    App().mainVC?.rootNV?.popToController(OrderDetailViewController.self, animated: false)
//                }else {
//                    self?.navigationController?.popViewController(animated: true)
//                }
//
//            case .error(let error):
//                //self?.callback?(false,_orderDetail)
//                self?.showAlertView(error.getMessage())
//            }
//        }
//    }
//
//    fileprivate func submitSignatureAndFinishOrder(_ file: AttachFileModel,_ name:String) {
//        guard let order:Order = order?.cloneObject() else { return }
//        let listStatus =  CoreDataManager.getListStatus()
//        for item in listStatus {
//            if item.code == StatusOrder.deliveryStatus.rawValue{
//                order.status = item
//                break
//            }
//        }
//        if hasNetworkConnection {
//            showLoadingIndicator()
//        }
//        SERVICES().API.submitSignature(file,order,name) {[weak self] (result) in
//            self?.dismissLoadingIndicator()
//            switch result{
//            case .object(_):
//                self?.showAlertView("order-has-delivered-successfully".localized) {[weak self](action) in
//                    if order.files == nil{
//                        order.files = []
//                    }
//                    order.files?.append(file)
//                    self?.callback?(true,order)
//                    self?.navigationController?.popViewController(animated: true)
//                }
//
//            case .error(let error):
//                self?.showAlertView(error.getMessage())
//                break
//            }
//        }
//    }
//}
//
////MARK: - SignatureViewControllerDelegate
//extension LoadUnloadOrderVC:SignatureViewControllerDelegate{
//    func signatureViewController(view: SignatureViewController, didCompletedSignature signature: AttachFileModel?, signName:String?) {
//        if let sig = signature{
//            submitSignatureAndFinishOrder(sig, signName ?? "")
//        }
//    }
//}
