//
//  HistoryNotifyDetailVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 12/19/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit

enum HistoryNotifyDetailSection:Int {
    case sectionInfo = 0
    case sectionComment
    
    static let count: Int = {
        var max: Int = 0
        while let _ = HistoryNotifyDetailSection(rawValue: max) { max += 1 }
        return max
    }()
}

class HistoryNotifyDetailVC: BaseViewController {
    
    //MARK: - OUTLET
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var updateStatusButton: UIButton?
    @IBOutlet weak var btnUnable: UIButton?
    @IBOutlet weak var vAction: UIView?
    
    
    //MARK: - VARIABLE
    fileprivate let cellIdentifier = "HistoryNotifyDetailCell"
    fileprivate let headerCellIdentifier = "HistoryNotifyDetailHeaderCell"
    fileprivate let discriptionCellIdentifier =  "HistoryNotifyDetailDiscCell"

    fileprivate var arrTitleHeader:[String] = []
    fileprivate var dataSectionInfo = [NotifylInforRow]()
    fileprivate var dataSectionComment = [NotifylInforRow]()
    
    
    var alertDetail = AlertModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        getAlertDetail()
    }
    
    override func updateUI()  {
        super.updateUI()
        ///
    }
    
    override func updateNavigationBar() {
        super.updateNavigationBar()
        setupNavigationService()
    }
    
    //MARK: - Initialize
    func setupTableView() {
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableViewAutomaticDimension
    }
    
    func setupNavigationService() {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.BackOnly, "Alert Detail".localized)
    }
    
    func initVar()  {
        arrTitleHeader = ["INFORMATION".localized,
                          "COMMENT".localized]
        
        setupDataDetailInforRows()
    }
    
    func setupDataDetailInforRows() {
        dataSectionInfo.removeAll()
        dataSectionComment.removeAll()
        
        let displayDateTimeVN = DateFormatter.displayDateTimeVN
        let stringDate = DateFormatter.serverDateFormater.date(from: E(alertDetail.created_at))
    
        let date = NotifylInforRow("Date".localized,E(displayDateTimeVN.string(from: stringDate ?? Date())))
        let status = NotifylInforRow("Status".localized,E(alertDetail.statusName))
        let ruleId = NotifylInforRow("Rule ID".localized, "\(alertDetail.ruleType?.id ?? 0)")
        let routeId = NotifylInforRow("Route ID".localized, "\(alertDetail.routeId ?? 0)")
        let driverName = NotifylInforRow("Driver Name".localized,alertDetail.driverName ?? "-")
        let truckName = NotifylInforRow("Truck Name".localized,alertDetail.truckName ?? "-")
        let tankerName = NotifylInforRow("Tanker Name".localized,alertDetail.tankerName ?? "-")
        let type = NotifylInforRow("Type".localized, alertDetail.ruleType?.name ?? "-")
        let comment = NotifylInforRow("Comment".localized,alertDetail.comment ?? "-")
        
        dataSectionInfo.append(status)
        dataSectionInfo.append(ruleId)
        dataSectionInfo.append(routeId)
        dataSectionInfo.append(driverName)
        dataSectionInfo.append(truckName)
        dataSectionInfo.append(tankerName)
        dataSectionInfo.append(type)
        dataSectionInfo.append(date)

        dataSectionComment.append(comment)
    }
}

// MARK: - UITableView
extension HistoryNotifyDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrTitleHeader.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let alertSection = HistoryNotifyDetailSection(rawValue: section) else {
            return 0
        }
        switch alertSection {
        case .sectionInfo:
            return dataSectionInfo.count
        case .sectionComment:
            return dataSectionComment.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as? HistoryNotifyDetailCell{
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
        let section = HistoryNotifyDetailSection(rawValue: indexPath.section)!
        switch section {
        case .sectionInfo:
            let item = dataSectionInfo[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                        for: indexPath) as? HistoryNotifyDetailCell {
                cell.infoRow = item
                cell.selectionStyle = .none
                
                if indexPath.row == dataSectionInfo.count - 1{
                    cell.vContent?.roundCornersLRB()
                }
                
                return cell
            }
        case .sectionComment:
            let item = dataSectionComment[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: discriptionCellIdentifier,
                                                        for: indexPath) as? HistoryNotifyDetailCell {
                cell.contentLabel?.text = item.content
                cell.selectionStyle = .none
                
                if indexPath.row == dataSectionComment.count - 1{
                    cell.vContent?.roundCornersLRB()
                }
                return cell
            }
        }
        
        return UITableViewCell()
    }
}

//MARK: - DMSNavigationServiceDelegate
extension HistoryNotifyDetailVC:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        self.navigationController?.popViewController(animated: true)
    }
}


//MARK: API
extension HistoryNotifyDetailVC{
    
    func getAlertDetail()  {
        guard let id = alertDetail.alertId else {
            return
        }
        self.showLoadingIndicator()
        SERVICES().API.getAlertDetail(alertId: id) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(let obj):
                self?.alertDetail = obj.data ?? AlertModel()
                self?.initVar()
                self?.updateUI()
                self?.tableView?.reloadData()
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}
