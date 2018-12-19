//
//  NotificationHistorys.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 12/17/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications
import SideMenu
import ObjectMapper

class HistoryNotifyVC: BaseViewController {
    
    @IBOutlet weak var tbvContent:UITableView?
    @IBOutlet weak var vAction:UIView?
    @IBOutlet weak var btnClear:UIButton?
    
    var arrContent:[AlertModel] = []
    var arrCoreNotifys:[ReceiveNotificationModel] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getAllMyHistoryNotifications()
    }
    
    override func updateNavigationBar() {
        super.updateNavigationBar()
        setupNavigationService()
    }
    
    func setupNavigationService() {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Menu_Calenda, "Alerts".localized)
    }
    
    func setupTableView() {
        tbvContent?.delegate = self
        tbvContent?.dataSource = self
        tbvContent?.addRefreshControl(self, action: #selector(onPullRefresh))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onPullRefresh() {
        getAllMyHistoryNotifications()
    }
    
    @IBAction func onTapRemoveAllNotify(btn:UIButton){
        App().showAlertView("Clear All Notifications?".localized,
                           positiveTitle: "OK".localized,
                           positiveAction: { (ok) in
                            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                            App().refreshBadgeIconNumber()
                            
        }, negativeTitle: "Cancel".localized) { (cancel) in
            //
        }
    }
}


//MARK: - UITableView
extension HistoryNotifyVC:UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrContent.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryNotifyCell", for: indexPath) as! HistoryNotifyCell
        let dto = arrContent[indexPath.row]
        let notifyDate = ServerDateFormater.date(from: E(dto.created_at))
        //cell.imvIcon?.image = dto.icon;
        cell.lblTitle?.text = dto.ruleType?.name
        cell.lblSubTitle?.text = dto.alert_msg;
        cell.lblDate?.text = Date.now.offsetLong(from: notifyDate ?? Date())
        cell.btnResolve?.isHidden = (dto.statusAlert == .resolved)
        cell.setStyleButtonStatus(dto)
        //cell.csHeightViewAction?.constant = dto.needResolve == true ? 50 : 0
        cell.delegate = self

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.onPullRefresh()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = arrContent[indexPath.row]
        let vc:HistoryNotifyDetailVC = HistoryNotifyDetailVC.loadSB(SB: .Notification)
        vc.alertDetail = alert
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


//MARK: - HistoryNotifyCellDelegate
extension HistoryNotifyVC:HistoryNotifyCellDelegate{
    func didSelectResolveAlert(cell: HistoryNotifyCell, btn: UIButton) {
        guard let indexPath = tbvContent?.indexPath(for: cell) else{
            return
        }
        let alert = arrContent[indexPath.row]
        PickerInputView.showInputViewWith(type: .PickerInputTextView,
                                          atVC: self, title: "Resolve alert",
                                          placeHolder: "Comment...") {[weak self] (success, content,_)  in
                                            alert.comment = content
                                            self?.resolveAlert(alert: alert)
        }
    }
}

//MARK: - HHeaderDelegate
extension HistoryNotifyVC:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        if Constants.isLeftToRight {
            if let  menuLeft = SideMenuManager.default.menuLeftNavigationController{
                present(menuLeft, animated: true, completion: nil)
            }
        }else{
            if let menuRight = SideMenuManager.default.menuRightNavigationController{
                present(menuRight, animated: true, completion: nil)
            }
        }
    }
}


//MARK: - Other Funtion
extension HistoryNotifyVC{
    
    func getAllMyHistoryNotifications()  {
        /*
        self.showLoadingIndicator()
        CoreDataManager.getListNotifys {[weak self] (success, listCoreNotifys) in
            self?.dismissLoadingIndicator()
            self?.tbvContent?.endRefreshControl()
            if success {
                self?.arrCoreNotifys = listCoreNotifys ?? []
                DispatchQueue.main.async {
                    self?.tbvContent?.reloadData()
                }
            }
        }
        */
        self.fetchData()
    }
    
    func fetchData(showLoading:Bool = true) {
        if showLoading {
            self.showLoadingIndicator()
        }
        SERVICES().API.getListAlerts {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.tbvContent?.endRefreshControl()
            switch result {
            case .object(let obj):
                self?.arrContent = obj.data?.data ?? []
                self?.tbvContent?.reloadData()
                
                guard let tbv  = self?.tbvContent else {return}
                if (self?.arrContent.count > 0){
                    UIView.removeViewNoItemAtParentView(tbv)
                }else {
                    UIView.addViewNoItemWithTitle("No data".localized,
                                                  intoParentView: tbv)
                }
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    func resolveAlert(alert:AlertModel)  {
        self.showLoadingIndicator()
        SERVICES().API.resolveAlert(alertId: alert.alertId ?? 0,
                                    comment: E(alert.comment)) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_ ):
                self?.fetchData(showLoading: false)
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}
