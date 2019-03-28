//
//  TaskListVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 10/22/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import SideMenu

class TaskListVC: BaseViewController {
    
    @IBOutlet weak var clvContent:UICollectionView?
    @IBOutlet weak var lblNoData: UILabel?

    var timeData:TimeDataItem?

    
    fileprivate let taskListIdebtifierCell = "TaskListClvCell"
    
    var dateStringFilter:String = Date().toString("MM/dd/yyyy")
    var dateFilter = Date()
    
    var taskList:[TaskModel] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getListTask()
    }
    
    override func updateNavigationBar() {
        setupNavigateBar()
    }
    
    override func reachabilityChangedNetwork(_ isAvailaibleNetwork: Bool) {
        super.reachabilityChangedNetwork(isAvailaibleNetwork)
        if isAvailaibleNetwork {
            fetchData()
        }else{
            
            DispatchQueue.main.async {[weak self] in
                self?.taskList = []
                self?.clvContent?.reloadData()
            }
        }
    }
    
    //MARK: - Intialize
    func setupNavigateBar() {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Menu, "".localized)
    }
    
    func setupCollectionView() {
        clvContent?.delegate = self
        clvContent?.dataSource = self
        clvContent?.addPullToRefetch(self, action: #selector(fetchData))
    }
    
    
    //MARK: - ACTION
    @IBAction func onbtnClickFilterByDate(btn:UIButton) {
        let arrHide = [TimeItemType.TimeItemTypeLastYear.rawValue,
                       TimeItemType.TimeItemTypeThisYear.rawValue,
                       TimeItemType.TimeItemTypeNextYear.rawValue]
        FilterByDatePopupView.showFilterListTimeAtView(view: btn,
                                                       atViewContrller: self,
                                                       timeData: timeData,
                                                       needHides: arrHide as [NSNumber]) {[weak self] (success, timeData) in
                                                 
                                                        //
        }
    }
}


//MARK: - DMSNavigationServiceDelegate
extension TaskListVC:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        showSideMenu()
    }
    
    /*
    func didSelectedLeftButton(_ sender: UIBarButtonItem) {
        let dateFormater =  DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        
        let currentDate = dateFormater.date(from: dateStringFilter)
        UIAlertController.showDatePicker(style: .actionSheet,
                                         mode: .date,
                                         title: "Select date".localized,
                                         currentDate: currentDate) {[weak self] (date) in
                                            
                                            self?.dateFilter = date
                                            self?.dateStringFilter = date.toString("MM/dd/yyyy")
                                            if self?.hasNetworkConnection ?? false{
                                                //self?.getDataFromServer()
                                                self?.getListTask()
                                                
                                            }else{
                                                //self?.getDataFromDBLocal(E(self?.dateStringFilter))
                                            }
        }
    }
     */
}


//MARK: - UICollectionViewDataSource
extension TaskListVC:UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.size.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: taskListIdebtifierCell, for: indexPath) as! TaskListClvCell
        
        cell.task = taskList[indexPath.row]
        cell.btnNumber?.setTitle("\(indexPath.row + 1)", for: .normal)
        
        return cell
    }
}


//MARK: - UICollectionViewDelegate
extension TaskListVC:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc: TaskDetailVC = .loadSB(SB: .Task)
        vc.task = taskList[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


//MARK - API
extension TaskListVC{
    
    @objc func fetchData()  {
        getListTask(isFetch: true)
    }
    
    func getListTask(isFetch:Bool = false) {
        if !isFetch {
            self.showLoadingIndicator()
        }
        SERVICES().API.getTaskList(dateStringFilter) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.clvContent?.endRefreshControl()
            switch result{
            case .object(let obj):
                self?.taskList = obj.data ?? []
                self?.taskList.sort(by: { (task1, task2) -> Bool in
                    return task1.task_id < task2.task_id
                })
                
                self?.lblNoData?.isHidden = obj.data?.count > 0
                self?.clvContent?.reloadData()
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
                break
            }
        }
    }
}
