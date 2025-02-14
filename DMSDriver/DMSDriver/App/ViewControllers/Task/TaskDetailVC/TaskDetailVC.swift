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
    fileprivate let FINISHED_STATUS = "3"
    fileprivate let CANCELLED_STATUS = "4"
    fileprivate let CELL_HEIGHT:CGFloat = 100.0
    fileprivate let HEADER_HEIGHT:CGFloat = 65.0
    fileprivate let FOOTER_HEIGHT:CGFloat = 15.0
    
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
        let statusItem = OrderDetailInforRow("Status".localized,status.statusName.localized)
        let urgency = OrderDetailInforRow("Urgency".localized , _task.urgency.name ?? "")
        let taskName = OrderDetailInforRow("Name".localized,"\(E(_task.name))")
        let driver = OrderDetailInforRow("Driver".localized,"\(E(_task.assignee.userName))")

        let startTime = OrderDetailInforRow("start-time".localized, (dlvy_start_time != nil) ? displayHour.string(from: dlvy_start_time!) : "")
        let endTime = OrderDetailInforRow("end-time".localized, (dlvy_end_time != nil) ? displayHour.string(from: dlvy_end_time!) : "")
        let address = OrderDetailInforRow("Address".localized,E(_task.address.address))
    
        taskInforStatus.append(statusItem)
        taskInforStatus.append(urgency)
        taskInforRows.append(taskName)
        taskInforRows.append(address)
        taskInforRows.append(driver)
        taskInforRows.append(startTime)
        taskInforRows.append(endTime)
        
        let instruction = OrderDetailInforRow("Instructions".localized,E(_task.instructions))
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
                          "Instructions".localized]
        
    }
    
    // MARK: ACTION
    @IBAction func didClickFinish(_ sender: UIButton) {
        handleFinishAction()
    }
    
    @IBAction func didClickUnableToStart(_ sender: UIButton) {
        handleCancelAction()
    }
    
    func handleUnableToStartAction() {
        let vc:ReasonListViewController = .loadSB(SB: .Common)
        vc.task = task
        vc.displayMode = .displayModeTask
        vc.didCancelSuccess =  { [weak self] (success, order) in
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleFinishAction() {
        self.updateTaskStatus(FINISHED_STATUS)
    }
    
    func handleCancelAction() {
        self.updateTaskStatus(CANCELLED_STATUS)
    }
    
    func showInputNote(_ statusNeedUpdate:String) {
    }
}


//MARK: - DMSNavigationServiceDelegate
extension TaskDetailVC:DMSNavigationServiceDelegate{
    func didSelectedBackAction() {
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
        return CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HEADER_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as? OrderDetailTableViewCell{
            headerCell.nameLabel?.text = arrTitleHeader[section];
            return headerCell;
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FOOTER_HEIGHT
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

