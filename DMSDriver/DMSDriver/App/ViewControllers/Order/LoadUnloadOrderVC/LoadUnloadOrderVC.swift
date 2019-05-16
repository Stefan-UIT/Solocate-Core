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
    private var dataOrigin:[Order.Detail] = []
    private var dataDisplay:[Order.Detail] = []

    var callback:LoadUnloadOrderVCCallback?
    
    var order:Order?
    
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
        App().navigationService.updateNavigationBar(.Menu,
                                                    "Packakes List".localized,
                                                    AppColor.white, true)
    }
    
    func initData()  {
        dataOrigin = order?.details ?? []
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
            
            for item in self?.order?.details ?? [] {
                
                if item.barCode == code {
                    
                    if self?.order?.statusOrder == StatusOrder.inProcessStatus {
                        item.status = .Loaded
                    }else if self?.order?.statusOrder == StatusOrder.pickupStatus {
                        item.status = .Unload
                    }
                    break
                }
            }
            
            self?.initData()
            self?.tbvContent?.reloadData()
            
            if self?.validUpdateStatusOrder() == true {
                
                if self?.order?.statusOrder == StatusOrder.inProcessStatus {
                    self?.updateStatusOrder(statusCode: StatusOrder.pickupStatus.rawValue)
                    
                }else {
                    
                    if self?.order?.isRequireSign() == false && self?.order?.isRequireImage() == false {
                        
                        self?.updateStatusOrder(statusCode: StatusOrder.deliveryStatus.rawValue)
                        
                    }else {
                       
                        if self?.order?.isRequireImage() ?? false{
                            self?.showAlertView("You need add least a picture to finish this order".localized) {[weak self](action) in
                                self?.showPictureViewController()
                            }
                            
                        }else if (self?.order?.isRequireSign() ?? false) {
                            self?.showAlertView("You need add Customer's signature to finish this order".localized) {[weak self](action) in
                                self?.showSignatureViewController()
                            }
                            
                        }else {
                            
                            let statusNeedUpdate = StatusOrder.deliveryStatus.rawValue
                            self?.updateStatusOrder(statusCode: statusNeedUpdate)
                        }
                    }
                }
            }
            
            /*
            self?.searchView?.vSearch?.tfSearch?.text = code
            self?.strSearch = code
            self?.doSearch(strSearch: code)
             */
        }
        self.navigationController?.present(vc, animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellContentIdentifier, for: indexPath) as! LoadUnLoadListCell
        let orderDetail = dataDisplay[indexPath.row]
        cell.configura(orderDetail: orderDetail)

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


//MARK : - LoadUnLoadListCellDelegate
extension LoadUnloadOrderVC:LoadUnLoadListCellDelegate{
    func didSelectedLoadUnload(cell: LoadUnLoadListCell, orderDetail: Order.Detail?) {
        guard let order = order,
              let detail = orderDetail,
              let indexPath = tbvContent?.indexPath(for: cell) else {
            return
        }
        let row = indexPath.row
        switch detail.status {
        case .NotLoad:
            orderDetail?.status = .Loaded
            
        case .Loaded:
            if order.statusOrder == .newStatus ||
                order.statusOrder == .inProcessStatus {
                detail.status = .NotLoad
            }else if (order.statusOrder == .pickupStatus) {
                detail.status = .Unload
            }
            
        case .Unload:
            if order.statusOrder == .pickupStatus {
                detail.status = .Loaded
            }
        }
        
        for var item in order.details ?? [] {
            if item.barCode == detail.barCode {
                item = detail
                break
            }
        }
        
        dataDisplay[row] = detail
        tbvContent?.reloadRows(at: [indexPath], with: .automatic)
        
        if validUpdateStatusOrder() == true {
            if order.statusOrder == StatusOrder.inProcessStatus {
                updateStatusOrder(statusCode: StatusOrder.pickupStatus.rawValue)
                
            }else {
                
                if order.isRequireSign() == false && order.isRequireImage() == false {
                    
                    updateStatusOrder(statusCode: StatusOrder.deliveryStatus.rawValue)
                    
                }else {
                    /*
                    self.callback?(true,order)
                    self.navigationController?.popViewController(animated: true)
                    */
            
                     if order.isRequireImage(){
                        self.showAlertView("You need add least a picture to finish this order".localized) {[weak self](action) in
                            self?.showPictureViewController()
                        }
                     
                    }else if (order.isRequireSign()) {
                        self.showAlertView("You need add Customer's signature to finish this order".localized) {[weak self](action) in
                            self?.showSignatureViewController()
                        }
                     
                     }else {
                     
                        let statusNeedUpdate = StatusOrder.deliveryStatus.rawValue
                        self.updateStatusOrder(statusCode: statusNeedUpdate)
                    }
                }
            }
        }
    }
    
    func validUpdateStatusOrder() -> Bool {
        var valid = true
        for item in order?.details ?? []  {
            if order?.statusOrder == StatusOrder.inProcessStatus {
                if item.status != .Loaded {
                   valid = false
                    break
                }
            }else if order?.statusOrder == StatusOrder.pickupStatus {
                if item.status != .Unload {
                    valid = false
                    break
                }
            }
        }

        return valid
    }
        
    func showPictureViewController() {
        let viewController = PictureViewController()
        let navi = BaseNV(rootViewController: viewController)
        navi.statusBarStyle = .lightContent
        viewController.order = order
        viewController.callback = {[weak self](success,order) in
            if success {
                self?.callback?(true,order)
            }
        }
        present(navi, animated: true, completion: nil)
    }
    
    func showSignatureViewController() {
        let viewController = SignatureViewController()
        viewController.delegate = self
        viewController.order = order
        self.callback?(true,order)
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
}
    
//MARK: - BaseSearchViewDelegate
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
                let isExist = item.barCode?.lowercased().contains(newSearchString!)
                return isExist ?? false
            })
            
        }else {
            dataDisplay = dataOrigin
        }
        if dataDisplay.count <= 0 {
            UIView.addViewNoItemWithTitle("No data".localized, intoParentView: self.view)
        }else {
            UIView.removeViewNoItemAtParentView(self.view!)
        }
        self.tbvContent?.reloadData()
    }
}


//MARK : - DMSNavigationServiceDelegate
extension LoadUnloadOrderVC:DMSNavigationServiceDelegate {
    
    func didSelectedBackOrMenu() {
        //
    }
}


//MARK: - API
extension LoadUnloadOrderVC {
    fileprivate func updateStatusOrder(statusCode: String, cancelReason:Reason? = nil) {
        guard let _orderDetail:Order = order?.cloneObject() else {
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
        
        SERVICES().API.updateOrderStatus(_orderDetail,reason: cancelReason) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.order = _orderDetail
                self?.order?.updateStatusDetailOrder()
                self?.callback?(true,_orderDetail)
                self?.navigationController?.popViewController(animated: true)

            case .error(let error):
                //self?.callback?(false,_orderDetail)
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    fileprivate func submitSignatureAndFinishOrder(_ file: AttachFileModel) {
        guard let order:Order = order?.cloneObject() else { return }
        let listStatus =  CoreDataManager.getListStatus()
        for item in listStatus {
            if item.code == StatusOrder.deliveryStatus.rawValue{
                order.status = item
                break
            }
        }
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        SERVICES().API.submitSignature(file,order) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.showAlertView("Order:#\(order.id) has delevered successfully.".localized) {[weak self](action) in
                    if order.files == nil{
                        order.files = []
                    }
                    order.files?.append(file)
                    self?.callback?(true,order)
                    self?.navigationController?.popViewController(animated: true)
                }
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
                break
            }
        }
    }
}

//MARK: - SignatureViewControllerDelegate
extension LoadUnloadOrderVC:SignatureViewControllerDelegate{
    func signatureViewController(view: SignatureViewController, didCompletedSignature signature: AttachFileModel?) {
        if let sig = signature {
            submitSignatureAndFinishOrder(sig)
        }
    }
}
