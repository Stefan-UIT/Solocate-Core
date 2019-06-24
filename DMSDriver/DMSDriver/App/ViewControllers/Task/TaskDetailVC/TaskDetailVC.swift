//
//  TaskDetailVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 10/22/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import CoreLocation


class TaskDetailVC: BaseViewController {
    
    enum TaskDetailSection:Int {
        case StatusSection = 0
        case DetailSection
        case InstructionSection
//        case DescriptionSection
        
        static let count: Int = {
            var max: Int = 0
            while let _ = TaskDetailSection(rawValue: max) { max += 1 }
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
    
    fileprivate let cellHeight: CGFloat = 70.0
    fileprivate let orderItemsPaddingTop: CGFloat = 40.0
    fileprivate let orderItemCellHeight: CGFloat = 130.0
    
    
    var dateStringFilter = Date().toString()
    
    var task: TaskModel? {
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
        if let _task = task {
            self.getTaskDetail(_task.id)
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
        App().navigationService.updateNavigationBar(.BackOnly, "task-detail".localized)
    }
    
    
    func setupDataDetailInforRows() {
        var _task:TaskModel!
        if task != nil {
            _task = task!
        }
        updateStatusButton?.isHidden = false
        taskInforStatus.removeAll()
        taskInforRows.removeAll()
        taskInstruction.removeAll()
        
        let displayDateVN = DateFormatter.displayDateVietNames
        let displayHour = DateFormatter.hourFormater
        let deliveryDate = DateFormatter.displayDateUS.date(from: E(_task.dlvy_date))
        let dlvy_start_time = DateFormatter.serverDateFormater.date(from: E(_task.dlvy_start_time))
        let dlvy_end_time = DateFormatter.serverDateFormater.date(from: E(_task.dlvy_end_time))
        let status = TaskStatus(rawValue: E(_task.status.code)) ?? TaskStatus.open
        let statusItem = OrderDetailInforRow("Status",status.statusName)
        let urgency = OrderDetailInforRow("Urgency" , _task.urgency.name ?? "")
//        let reason = OrderDetailInforRow("failure-cause",E(_task.reason?.name))
//        let mess = OrderDetailInforRow("Message",E(_task.reason_msg))
        let taskName = OrderDetailInforRow("Name","\(E(_task.name))")
        let driver = OrderDetailInforRow("Driver","\(E(_task.assignee.userName))")
        let taskId = OrderDetailInforRow("TaskId","\(_task.id)")
        let startTime = OrderDetailInforRow("start-time", (dlvy_start_time != nil) ? displayHour.string(from: dlvy_start_time!) : "")
        let endTime = OrderDetailInforRow("end-time", (dlvy_end_time != nil) ? displayHour.string(from: dlvy_end_time!) : "")
//        let date = OrderDetailInforRow("Date",(deliveryDate != nil) ? displayDateVN.string(from: deliveryDate!) : "")
//        let clientName = OrderDetailInforRow("client-name",E(_task.client_name))
//        let customerName = OrderDetailInforRow("customer-name" ,E(_task.customer_name))
//        let collectCall = OrderDetailInforRow("Collectcall",E(_task.collect_call))
//        let coordinationPhone = OrderDetailInforRow("coordination-phone", E(_task.coord_phone))
//        let receiverName = OrderDetailInforRow("receiver-name",E(_task.rcvr_name))
//        let phone = OrderDetailInforRow("Phone", E(_task.rcvr_phone))
        let address = OrderDetailInforRow("Address",E(_task.address.address))
    
        taskInforStatus.append(statusItem)
        taskInforStatus.append(urgency)
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
        
        let instruction = OrderDetailInforRow("Instruction",E(_task.instructions))
        taskInstruction.append(instruction)
    }
    
    
    override func updateUI()  {
        super.updateUI()
        DispatchQueue.main.async {[weak self] in
            self?.vAction?.isHidden = (self?.task == nil)
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
        arrTitleHeader = ["task-status".localized,
                          "task-information".localized,
//                          "Information".localized,
                          "Instructions".localized]
        
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
        vc.task = task
        vc.displayMode = .displayModeTask
        vc.didCancelSuccess =  { [weak self] (success, order) in
            //self?.task = order as? TaskModel
            //self?.didUpdateStatus?((self?.orderDetail)!, nil)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleFinishAction() {
//        App().showAlertView("are-you-sure-you-want-to-finish-this-task?".localized,
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
//        App().showAlertView("are-you-sure-you-want-to-cancel-this-task?".localized,
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
extension TaskDetailVC:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
       self.navigationController?.popViewController(animated: true)
    }
}


// MARK: - Private methods
extension TaskDetailVC {
    func updateOrderStatus(_ status: String) {
        ///
    }
}


// MARK: - UITableView
extension TaskDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrTitleHeader.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section:TaskDetailSection = TaskDetailSection(rawValue: section)!
        switch section {
        case .StatusSection:
            return taskInforStatus.count
        case .DetailSection:
            return taskInforRows.count
        case .InstructionSection:
            return taskInstruction.count;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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
        let section:TaskDetailSection = TaskDetailSection(rawValue: indexPath.section)!
        switch section {
        case .StatusSection:
            return cell(items: taskInforStatus, tableView, indexPath)
        case .DetailSection:
            return cell(items: taskInforRows, tableView, indexPath)
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
                    vc.orderLocation = _task.location
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
fileprivate extension TaskDetailVC{
    
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
        guard  let statusTask = TaskStatus(rawValue: E(task?.status.code)) else {
            return
        }
        vAction?.isHidden = (statusTask == .delivered ||
                             statusTask == .cancel)
    }
}


//MARK: API
extension TaskDetailVC{
    
    @objc func fetchData()  {
        getTaskDetail(task?.id ?? 0, true)
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
                self?.task = obj.data
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    func updateTaskStatus(_ status:String) {
        self.showLoadingIndicator()
        SERVICES().API.updateTaskStatusTask(task?.id ?? 0, status) {[weak self] (result) in
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

