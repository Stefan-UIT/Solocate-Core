//
//  RentingOrderDetailVC.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 9/24/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class RentingOrderDetailVC: BaseViewController {
    
    enum RentingOrderSection:Int {
        case OrderInfo = 0
        case SKUS
        
        static let count: Int = {
            var max: Int = 0
            while let _ = RentingOrderSection(rawValue: max) { max += 1 }
            return max
        }()
    }
    
    enum UpdateStatusButton {
        case START_RENTING_ORDER
        case FINISH_RENTING_ORDER
    }
    
    @IBOutlet weak var tbvContent: UITableView?
    @IBOutlet weak var statusButtonView: UIView!
    @IBOutlet weak var updateStatusButton: UIButton!
    @IBOutlet weak var cancelStatusButton: UIButton!
    
    @IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
    fileprivate var rentingOrderInfo = [RentingOrderDetailInforRow]()
    fileprivate var rentingSKUS = [RentingOrderDetailInforRow]()
    fileprivate let headerCellIdentifier = "RentingOrderDetailHeaderCell"
    fileprivate let rentingDetailInfocellIdentifier = "RentingOrderDetailInfoTableViewCell"
    fileprivate var scanItems = [String]()
    fileprivate var arrTitleHeader:[String] = []
    
    fileprivate let itemsIndex = 8
    fileprivate var scannedObjectIndexs = [Int]()
    fileprivate var shouldFilterOrderItemsList = true
    
    fileprivate let cellHeight: CGFloat = 65.0
    fileprivate let orderItemsPaddingTop: CGFloat = 40.0
    fileprivate let orderItemCellHeight: CGFloat = 130.0
    
    var dateStringFilter = Date().toString()
    var rentingOrder: RentingOrder?
    var typeUpdateBtn: UpdateStatusButton = .START_RENTING_ORDER
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        fetchData(showLoading: true)
        setupTableView()
        initVar()
        setupDataDetailInforRows()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func updateNavigationBar() {
        setupNavigateBar()
    }
    
    //MARK: - Intialize
    func setupNavigateBar() {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.BackOnly, "renting-order-detail".localized)
    }
    
    func setupDataDetailInforRows() {
        var _rentingOrder:RentingOrder!
        if rentingOrder != nil {
            _rentingOrder = rentingOrder!
        }
//        updateStatusButton?.isHidden = false
//        taskInforStatus.removeAll()
//        taskInforRows.removeAll()
//        taskInstruction.removeAll()
        rentingOrderInfo.removeAll()
        rentingSKUS.removeAll()
        
        // Cell Renting Detail Info
        let rentingOrderID = RentingOrderDetailInforRow("renting-order-id".localized,"\(_rentingOrder.id)")
        let rentingRefCode = RentingOrderDetailInforRow("ref-code".localized,"\(_rentingOrder.referenceCode)")
        let rentingCustomer = RentingOrderDetailInforRow("customer-name".localized, _rentingOrder.rentingOrderCustomer?.userName ?? "")
        let rentingDateRange = RentingOrderDetailInforRow("date-range".localized,"\(_rentingOrder.startDate ?? "")"+" - "+"\(_rentingOrder.endDate ?? "")")
        
        rentingOrderInfo.append(rentingOrderID)
        rentingOrderInfo.append(rentingRefCode)
        rentingOrderInfo.append(rentingCustomer)
        rentingOrderInfo.append(rentingDateRange)
        
    }
    
    override func updateUI()  {
        super.updateUI()
        self.updateStatusButtonView()
        tbvContent?.reloadData()
    }
    
    func initVar() {
        arrTitleHeader = ["order-info".localized,
                          "details".localized]
    }
    
    func setupTableView() {
        tbvContent?.estimatedRowHeight = cellHeight
        tbvContent?.rowHeight = UITableView.automaticDimension
    }
    
    func updateStatusButtonView() {
        if rentingOrder?.rentingOrderStatus?.code == RentingOrderStatusCode.Finished.rawValue || rentingOrder?.rentingOrderStatus?.code == RentingOrderStatusCode.Cancelled.rawValue {
            self.handleShowingUpdateStatusView(false)
        } else {
            cancelStatusButton.setTitle("Cancel".localized.uppercased(), for: .normal)
            cancelStatusButton.backgroundColor = AppColor.redColor
            self.handleShowingUpdateStatusView(true)
            updateStatusButton.isHidden = true
        }
        if rentingOrder?.rentingOrderStatus?.code == RentingOrderStatusCode.InProgress.rawValue {
            updateStatusButton.setTitle("Finish".localized.uppercased(), for: .normal)
            updateStatusButton.backgroundColor = AppColor.greenColor
            typeUpdateBtn = .FINISH_RENTING_ORDER
            self.handleShowingUpdateStatusView(true)
        } else if rentingOrder?.rentingOrderStatus?.code == RentingOrderStatusCode.FullyAssigned.rawValue {
            updateStatusButton.setTitle("Start".localized.uppercased(), for: .normal)
            updateStatusButton.backgroundColor = AppColor.greenColor
            self.handleShowingUpdateStatusView(true)
            typeUpdateBtn = .START_RENTING_ORDER
        }
    }
    
    func handleShowingUpdateStatusView(_ isShow: Bool) {
        tableViewBottomConstraint.constant = isShow ? 50 : 0
        statusButtonView.isHidden = !isShow
        updateStatusButton.isHidden = !isShow
    }
    
    // MARK: - Action
    @IBAction func didTapUpdateStatusButton(_ sender: Any) {
        switch typeUpdateBtn {
        case .START_RENTING_ORDER:
            self.updateRentingOrderStatusWith(RentingOrderStatusCode.InProgress.code, rentingOrder: rentingOrder!)
        case .FINISH_RENTING_ORDER:
            self.updateRentingOrderStatusWith(RentingOrderStatusCode.Finished.code, rentingOrder: rentingOrder!)
        }
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.updateRentingOrderStatusWith(RentingOrderStatusCode.Cancelled.code, rentingOrder: rentingOrder!)
    }
    
    func handleFisnishedAction() {
        // Finished Order and show NotePopup
    }
    
    func handleCancelAction() {
        
    }
    
}

extension RentingOrderDetailVC: DMSNavigationServiceDelegate {
    func didSelectedBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableView
extension RentingOrderDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrTitleHeader.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section:RentingOrderSection = RentingOrderSection(rawValue: section)!
        switch section {
        case .OrderInfo:
            return rentingOrderInfo.count
        case .SKUS:
            return rentingOrder?.rentingOrderDetails?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as? RentingOrderDetailInfoTableViewCell{
            headerCell.nameLabel?.text = arrTitleHeader[section]
            if section == 0 {
                headerCell.contentLabel?.isHidden = false
                headerCell.contentLabel?.text = rentingOrder?.rentingOrderStatus?.name?.localized
                headerCell.contentLabel?.textColor = rentingOrder?.rentingOrderStatusColor
                
            } else {
                headerCell.contentLabel?.isHidden = true
            }
            return headerCell
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view:UIView = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section:RentingOrderSection = RentingOrderSection(rawValue: indexPath.section)!
        switch section {
        case .OrderInfo:
            return rentingOrderInfoCell(items: rentingOrderInfo, tableView, indexPath)
        case .SKUS:
            let cell = tbvContent?.dequeueReusableCell(withIdentifier: "RentingOrderDetailTableViewCell", for: indexPath) as! RentingOrderDetailTableViewCell
            guard let rentingOrderDetail = rentingOrder?.rentingOrderDetails?[indexPath.row] else {return cell}
            cell.configureCellWithRentingOrderDetail(rentingOrderDetail)
            return cell
        }
            
    }
    
    func rentingOrderInfoCell(items:[RentingOrderDetailInforRow],_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: rentingDetailInfocellIdentifier, for: indexPath) as! RentingOrderDetailInfoTableViewCell
        cell.rentingOrderDetailItem = item
        cell.selectionStyle = .none
        return cell
        
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        /*
//         let orderSection:OrderDetailSection = OrderDetailSection(rawValue: indexPath.section)!
//         let row = indexPath.row
//         switch orderSection {
//         case .sectionInformation:
//
//         if row == informationRows.count - 2 ||
//         row == informationRows.count - 3 ||
//         row == informationRows.count - 4{// Phone row
//         let item = informationRows[row]
//
//         if !isEmpty(item.content){
//         let urlString = "tel://\(item.content)"
//         if let url = URL(string: urlString) {
//         UIApplication.shared.open(url, options: [:], completionHandler: nil)
//         }
//         }
//
//         }else if (row == informationRows.count - 1){ //Address row
//         let vc:OrderDetailMapViewController = .loadSB(SB: .Order)
//         if let _task = task {
//         vc.orderLocation = _item.location
//         }
//         self.navigationController?.pushViewController( vc, animated: true)
//         }
//
//         default:
//         break
//         }
//         */
//    }
}

//MARK: API
extension RentingOrderDetailVC {
    func fetchData(showLoading:Bool = false)  {
        getRentingOrderDetail()
    }
    
    private func getRentingOrderDetail(isFetch:Bool = false) {
        if hasNetworkConnection &&
            ReachabilityManager.isCalling == false {
            guard let _rentingOrderID = rentingOrder?.id else { return }
            if !isFetch {
                showLoadingIndicator()
            }
            SERVICES().API.getRentingOrderDetail(rentingOrderId: "\(_rentingOrderID)") {[weak self] (result) in
                self?.dismissLoadingIndicator()
                switch result{
                case .object(let object):
                    self?.rentingOrder = object.data
//                    self?.rootVC?.order =  self?.orderDetail
                    self?.initVar()
                    self?.updateUI()
                    
                    //CoreDataManager.updateOrderDetail(object) // update orderdetail to DB local
                case .error(let error):
                    self?.showAlertView(error.getMessage())
                }
            }
            
        }else {
            
            //Get data from local DB
            /*
             if let _order = self.orderDetail{
             CoreDataManager.queryOrderDetail(_order.id, callback: {[weak self] (success,data) in
             guard let strongSelf = self else{return}
             strongSelf.orderDetail = data
             strongSelf.updateUI()
             })
             }
             */
        }
    }
    
    func updateRentingOrderStatusWith(_ rentingOrderStatus: Int, rentingOrder: RentingOrder){
        SERVICES().API.updateRentingOrderStatusWith(rentingOrderStatus, rentingOrder: rentingOrder) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.showAlertView(MSG_UPDATED_SUCCESSFUL)
                self?.fetchData()
                break
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
}
