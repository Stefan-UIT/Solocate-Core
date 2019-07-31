//
//  TaskDetailVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 10/22/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import CoreLocation


class ReturnedItemDetailVC: BaseViewController {
    
    enum ReturnedItemSection:Int {
        case StatusSection = 0
        case DetailSection
        case QuantitySection
        case InstructionSection
//        case DescriptionSection
        
        static let count: Int = {
            var max: Int = 0
            while let _ = ReturnedItemSection(rawValue: max) { max += 1 }
            return max
        }()
    }
    
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var updateStatusButton: UIButton?
    @IBOutlet weak var btnUnable: UIButton?
    @IBOutlet weak var vAction: UIView?
    
    
    fileprivate var taskInforStatus = [OrderDetailInforRow]()
    fileprivate var taskInforRows = [OrderDetailInforRow]()
    fileprivate var taskInstruction = [OrderDetailInforRow]()
    
    fileprivate let cellIdentifier = "OrderDetailTableViewCell"
    fileprivate let headerCellIdentifier = "OrderDetailHeaderCell"
    fileprivate let addressCellIdentifier =  "OrderDetailAddressCell"
    fileprivate let orderDropdownCellIdentifier = "OrderDetailDropdownCell"
    fileprivate var scanItems = [String]()
    fileprivate var arrTitleHeader:[String] = []
    
    fileprivate let itemsIndex = 8
    fileprivate var scannedObjectIndexs = [Int]()
    fileprivate var shouldFilterOrderItemsList = true
    
    fileprivate let cellHeight: CGFloat = 65.0
    fileprivate let orderItemsPaddingTop: CGFloat = 40.0
    fileprivate let orderItemCellHeight: CGFloat = 130.0
    
    
    var dateStringFilter = Date().toString()
    
    var item: ReturnedItem? {
        didSet {
            setupDataDetailInforRows()
            updateButtonStatus()
            tableView?.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        initVar()
        setupDataDetailInforRows()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _item = item {
            self.getTaskDetail(_item.id)
        }
    }
    
    override func reachabilityChangedNetwork(_ isAvailaibleNetwork: Bool) {
        super.reachabilityChangedNetwork(isAvailaibleNetwork)
        //checkConnetionInternet?(notification, isAvailaibleNetwork)

    }
    
    override func updateNavigationBar() {
        setupNavigateBar()
    }
    
    //MARK: - Intialize
    func setupNavigateBar() {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.BackOnly, "returned-item-detail".localized)
    }
    
    
    func setupDataDetailInforRows() {
        var _item:ReturnedItem!
        if item != nil {
            _item = item!
        }
        updateStatusButton?.isHidden = false
        taskInforStatus.removeAll()
        taskInforRows.removeAll()
        taskInstruction.removeAll()
        
        let displayDateVN = DateFormatter.displayDateVietNames
        let displayHour = DateFormatter.hourFormater
        let deliveryDate = DateFormatter.displayDateUS.date(from: E(_item.dlvy_date))
        let dlvy_start_time = DateFormatter.serverDateFormater.date(from: E(_item.dlvy_start_time))
        let dlvy_end_time = DateFormatter.serverDateFormater.date(from: E(_item.dlvy_end_time))
        let status = TaskStatus(rawValue: E(_item.status.code)) ?? TaskStatus.open
        let statusItem = OrderDetailInforRow("Status".localized,status.statusName.localized)
//        let urgency = OrderDetailInforRow("Urgency".localized , _item.urgency.name ?? "")
//        let reason = OrderDetailInforRow("failure-cause",E(_item.reason?.name))
//        let mess = OrderDetailInforRow("Message",E(_item.reason_msg))
        let taskName = OrderDetailInforRow("Name".localized,"\(E(_item.name))")
        let driver = OrderDetailInforRow("Driver".localized,"\(E(_item.assignee.userName))")

        let startTime = OrderDetailInforRow("start-time".localized, (dlvy_start_time != nil) ? displayHour.string(from: dlvy_start_time!) : "")
        let endTime = OrderDetailInforRow("end-time".localized, (dlvy_end_time != nil) ? displayHour.string(from: dlvy_end_time!) : "")
//        let date = OrderDetailInforRow("Date",(deliveryDate != nil) ? displayDateVN.string(from: deliveryDate!) : "")
//        let clientName = OrderDetailInforRow("client-name",E(_item.client_name))
//        let customerName = OrderDetailInforRow("customer-name" ,E(_item.customer_name))
//        let collectCall = OrderDetailInforRow("Collectcall",E(_item.collect_call))
//        let coordinationPhone = OrderDetailInforRow("coordination-phone", E(_item.coord_phone))
//        let receiverName = OrderDetailInforRow("receiver-name",E(_item.rcvr_name))
//        let phone = OrderDetailInforRow("Phone", E(_item.rcvr_phone))
        let address = OrderDetailInforRow("Address".localized,E(_item.address.address))
    
        taskInforStatus.append(statusItem)
//        taskInforStatus.append(urgency)
//        if  status == TaskStatus.cancel {
//            taskInforStatus.append(reason)
//            taskInforStatus.append(mess)
//        }
        
//        taskInforRows.append(taskId)
        taskInforRows.append(taskName)
        taskInforRows.append(address)
        taskInforRows.append(driver)
        taskInforRows.append(startTime)
        taskInforRows.append(endTime)
//        taskInforRows.append(date)
        
//        informationRows.append(clientName)
//        informationRows.append(customerName)
//        informationRows.append(receiverName)
//        informationRows.append(phone)
//        informationRows.append(collectCall)
//        informationRows.append(coordinationPhone)
        
        let instruction = OrderDetailInforRow("Instructions".localized,E(_item.instructions))
        taskInstruction.append(instruction)
    }
    
    
    override func updateUI()  {
        super.updateUI()
        DispatchQueue.main.async {[weak self] in
            self?.vAction?.isHidden = (self?.item == nil)
            self?.updateButtonStatus()
            self?.setupTableView()
        }
    }
    
    func setupTableView() {
        tableView?.estimatedRowHeight = cellHeight
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.addRefreshControl(self, action: #selector(fetchData))
    }
    
    func initVar()  {
        arrTitleHeader = ["Status".localized,
                          "Information".localized,
//                          "Information".localized,
            "Returned Item Quantity".localized,
                          "order_detail_notes".localized]
        
    }
    
    // MARK: ACTION
    @IBAction func didClickFinish(_ sender: UIButton) {
        handleFinishAction()
    }
    
    @IBAction func didClickUnableToStart(_ sender: UIButton) {
//        handleUnableToStartAction()
        handleCancelAction()
    }
    
    func handleUnableToStartAction() {
        let vc:ReasonListViewController = .loadSB(SB: .Common)
//        vc.task = task
        vc.displayMode = .displayModeTask
        vc.didCancelSuccess =  { [weak self] (success, order) in
            //self?.task = order as? TaskModel
            //self?.didUpdateStatus?((self?.orderDetail)!, nil)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleFinishAction() {
//        App().showAlertView("are-you-sure-you-want-to-finish-this-task".localized,
//                            positiveTitle: "Finish".localized,
//                            positiveAction: { (hasOK) in
//
//                        self.updateTaskStatus("3")
//        }, negativeTitle: "cancel".localized) { (hasCancel) in
//            //
//        }
        self.updateTaskStatus("3")
    }
    
    func handleCancelAction() {
//        App().showAlertView("are-you-sure-you-want-to-cancel-this-task".localized,
//                            positiveTitle: "Confirm".localized,
//                            positiveAction: { (hasOK) in
//
//                                self.updateTaskStatus("4")
//        }, negativeTitle: "cancel".localized) { (hasCancel) in
//            //
//        }
        self.updateTaskStatus("4")
    }
    
    func showInputNote(_ statusNeedUpdate:String) {
        //
    }
}


//MARK: - DMSNavigationServiceDelegate
extension ReturnedItemDetailVC:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
       self.navigationController?.popViewController(animated: true)
    }
}


// MARK: - Private methods
extension ReturnedItemDetailVC {
    func updateOrderStatus(_ status: String) {
        ///
    }
}


// MARK: - UITableView
extension ReturnedItemDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrTitleHeader.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section:ReturnedItemSection = ReturnedItemSection(rawValue: section)!
        switch section {
        case .StatusSection:
            return taskInforStatus.count
        case .DetailSection:
            return taskInforRows.count
        case .QuantitySection:
            return 1
        case .InstructionSection:
            return taskInstruction.count;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as? OrderDetailTableViewCell{
            headerCell.nameLabel?.text = arrTitleHeader[section];
            return headerCell;
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
        let section:ReturnedItemSection = ReturnedItemSection(rawValue: indexPath.section)!
        switch section {
        case .StatusSection:
            return cell(items: taskInforStatus, tableView, indexPath)
        case .DetailSection:
            return cell(items: taskInforRows, tableView, indexPath)
        case .QuantitySection:
            return quantityCell(tableView, indexPath)
        case .InstructionSection:
            return cellDiscription(tableView, indexPath)
        }
        
//        return UITableViewCell()
    }
    
    func cell(items:[OrderDetailInforRow],_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OrderDetailTableViewCell
        cell.orderDetailItem = item
        cell.selectionStyle = .none
        cell.vContent?.cornerRadius = 0
        if indexPath.row == items.count - 1{
            cell.vContent?.roundCornersLRB()
        }
        
        return cell

    }
    
    func quantityCell(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        guard let _item = self.item else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReturnedItemQuantityCell", for: indexPath) as! ReturnedItemQuantityCell
        cell.configureCellWithDetail(_item)
        cell.vContent?.cornerRadius = 0

        return cell
        
    }
    
    func cellDiscription(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: addressCellIdentifier, for: indexPath) as! OrderDetailTableViewCell
        let description = taskInstruction[0]
        cell.orderDetailItem = description
        cell.selectionStyle = .none
        cell.vContent?.roundCornersLRB()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        let orderSection:OrderDetailSection = OrderDetailSection(rawValue: indexPath.section)!
        let row = indexPath.row
        switch orderSection {
        case .sectionInformation:
            
            if row == informationRows.count - 2 ||
                row == informationRows.count - 3 ||
                row == informationRows.count - 4{// Phone row
                let item = informationRows[row]
                
                if !isEmpty(item.content){
                    let urlString = "tel://\(item.content)"
                    if let url = URL(string: urlString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                
            }else if (row == informationRows.count - 1){ //Address row
                let vc:OrderDetailMapViewController = .loadSB(SB: .Order)
                if let _task = task {
                    vc.orderLocation = _item.location
                }
                self.navigationController?.pushViewController( vc, animated: true)
            }
            
        default:
            break
        }
         */
    }
}


//MARK: - Otherfuntion
fileprivate extension ReturnedItemDetailVC{
    
    func scrollToBottom(){
        DispatchQueue.main.async {[weak self] in
            let indexPath = IndexPath(row: 0, section: OrderDetailSection.sectionDescription.rawValue)
            self?.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func updateButtonStatus() {
        updateStatusButton?.backgroundColor = AppColor.mainColor
        btnUnable?.backgroundColor = AppColor.grayColor
        btnUnable?.borderWidth = 1;
        btnUnable?.borderColor = AppColor.grayBorderColor
        vAction?.isHidden = true
        updateStatusButton?.setTitle("Finish".localized.uppercased(), for: .normal)
        btnUnable?.setTitle("cancel".localized.uppercased(), for: .normal)
        guard  let statusTask = TaskStatus(rawValue: E(item?.status.code)) else {
            return
        }
        vAction?.isHidden = (statusTask == .delivered ||
                             statusTask == .cancel)
    }
}


//MARK: API
extension ReturnedItemDetailVC{
    
    @objc func fetchData()  {
        getTaskDetail(item?.id ?? 0, true)
    }
    
    func getTaskDetail(_ taskId: Int, _ isFetch:Bool = false) {
        if !isFetch {
            self.showLoadingIndicator()
        }
        SERVICES().API.getTaskDetail(taskId) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.tableView?.endRefreshControl()
            switch result{
            case .object(let obj):
                let task = obj.data
                self?.item = task?.toReturnedItems()
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    func updateTaskStatus(_ status:String) {
        self.showLoadingIndicator()
        SERVICES().API.updateTaskStatusTask(item?.id ?? 0, status) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.tableView?.endRefreshControl()
            switch result{
            case .object(_ ):
                self?.fetchData()
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}

