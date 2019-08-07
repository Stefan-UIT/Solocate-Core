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
        if let _item = item {
            self.getTaskDetail(_item.id)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        let status = TaskStatus(rawValue: E(_item.status.code)) ?? TaskStatus.open
        let statusItem = OrderDetailInforRow("Status".localized,status.statusName.localized)
        let taskName = OrderDetailInforRow("Name".localized,"\(E(_item.name))")
        let routeID = OrderDetailInforRow("Route".localized,"\(_item.routeID ?? 0)")

        let startTime = OrderDetailInforRow("start-time".localized, Slash(_item.dlvy_start_time))
        let endTime = OrderDetailInforRow("end-time".localized, Slash(_item.dlvy_end_time))
        let instruction = OrderDetailInforRow("Instructions".localized,Slash(_item.instructions))
        let note = OrderDetailInforRow("Note".localized,Slash(_item.note))
        
        var assigneesName = ""
        for i in _item.assignees {
            assigneesName = assigneesName + ", " + Slash(i.userName)
        }
        
        let assigneesRow = OrderDetailInforRow("Assignees".localized,assigneesName)
    
        taskInforStatus.append(statusItem)
        taskInforRows.append(taskName)
        taskInforRows.append(routeID)
        taskInforRows.append(assigneesRow)
        taskInforRows.append(startTime)
        taskInforRows.append(endTime)
        taskInforRows.append(instruction)
        taskInforRows.append(note)
//        taskInstruction.append(instruction)
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
    
    func presentSignatureViewController()  {
        let viewController = SignatureViewController()
        viewController.isFromOrderDetail = false
        viewController.delegate = self
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    func showNotePopUp(completionHandler:@escaping (_ isSkip:Bool, _ note:String) -> Void) {
        let alert = UIAlertController(title: "Note".localized, message: "Please enter note for this returned item", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "submit".localized, style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let value = textField?.text ?? ""
            if let _item = self.item {
                _item.note = value
            }
            
            completionHandler(false,value)
            
            // call
            
        }))
        
        alert.addAction(UIAlertAction(title: "skip".localized, style: .cancel, handler: {
            action in
            completionHandler(true,"")
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: ACTION
    
    
    @IBAction func onFinishButtonTouchUp(_ sender: UIButton) {
        if isRampManagerMode {
            self.presentSignatureViewController()
        } else {
            showNotePopUp { (isSkip, note) in
                if isSkip || note.isEmpty {
                    self.finishReturnedItem()
                    return
                }
                self.updateItemInfo(signedFile: nil, signName: nil, note: note )
            }
        }
        
        return
        
    }
    
    @IBAction func onCancelButtonTouchUp(_ sender: UIButton) {
    }
    
    
    @IBAction func onRejectButtonTouchUp(_ sender: UIButton) {
    }
    
    @IBAction func didClickFinish(_ sender: UIButton) {
        handleFinishAction()
    }
    
    @IBAction func didClickUnableToStart(_ sender: UIButton) {
//        handleUnableToStartAction()
        handleCancelAction()
    }
    
    func finishReturnedItem() {
        guard let _item = self.item else { return }
        SERVICES().API.finishReturnedItem(_item.id) { [weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.tableView?.endRefreshControl()
            switch result{
            case .object(let obj):
                let message = obj.message ?? ""
                self?.showAlertView(message)
                self?.getTaskDetail(_item.id)
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }

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
    func didSelectedBackAction() {
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
//            return taskInstruction.count;
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section:ReturnedItemSection = ReturnedItemSection(rawValue: section)!
        if section == ReturnedItemSection.InstructionSection {
            return CGFloat.leastNormalMagnitude
        }
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
        let section:ReturnedItemSection = ReturnedItemSection(rawValue: section)!
        if section == ReturnedItemSection.InstructionSection {
            return CGFloat.leastNormalMagnitude
        }
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
//        updateStatusButton?.backgroundColor = AppColor.mainColor
//        btnUnable?.backgroundColor = AppColor.grayColor
//        btnUnable?.borderWidth = 1;
//        btnUnable?.borderColor = AppColor.grayBorderColor
//        vAction?.isHidden = true
//        updateStatusButton?.setTitle("Finish".localized.uppercased(), for: .normal)
//        btnUnable?.setTitle("cancel".localized.uppercased(), for: .normal)
        guard  let _item = item, let statusTask = TaskStatus(rawValue: E(_item.status.code)) else {
            return
        }
        
        vAction?.isHidden = !_item.isAllowedToActions
    }
}


//MARK: API
extension ReturnedItemDetailVC{
    
    @objc func fetchData()  {
        getTaskDetail(item?.id ?? 0, true)
    }
    
    func getTaskDetail(_ itemID: Int, _ isFetch:Bool = false) {
        if !isFetch {
            self.showLoadingIndicator()
        }
        SERVICES().API.getReturnedItemDetail(itemID) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.tableView?.endRefreshControl()
            switch result{
            case .object(let obj):
//                let task = obj.data
//                self?.item = task?.toReturnedItems()
                self?.item = obj.data
                
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

// MARK: - SignatureViewControllerDelegate
extension ReturnedItemDetailVC:SignatureViewControllerDelegate{
    func signatureViewController(view: SignatureViewController, didCompletedSignature signature: AttachFileModel?, signName:String?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.showNotePopUp(completionHandler: { (isSkip, value) in
                let note = (isSkip) ? nil : value
                self.updateItemInfo(signedFile: signature, signName: signName, note: note)
            })
        })
        
    }
    
    func updateItemInfo(signedFile:AttachFileModel?, signName:String?, note:String?) {
        guard let _item = self.item else { return }
        self.showLoadingIndicator()
        SERVICES().API.updateReturnedItem(_item.id, returnedQty: _item.returnedQuantity, signedFile: signedFile, signName: signName, note: note) { [weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.tableView?.endRefreshControl()
            switch result{
            case .object(let obj):
//                let message = obj.message
//                self?.showAlertView(message ?? "")
                self?.finishReturnedItem()
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}

