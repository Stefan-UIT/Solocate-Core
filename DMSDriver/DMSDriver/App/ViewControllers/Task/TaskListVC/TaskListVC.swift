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
    @IBOutlet weak var filterLabel: UILabel!

    fileprivate let taskListIdebtifierCell = "TaskListClvCell"
    
    var dateStringFilter:String = Date().toString("MM/dd/yyyy")
    var dateFilter = Date()
    var taskList:[TaskModel] = []
    var selectedTimeData:TimeDataItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        initVar()
        updateUI()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getListTask(timeDataItem: self.selectedTimeData!, isFetch: true)
    }
    
    override func updateNavigationBar() {
        setupNavigateBar()
    }
    
    override func updateUI()  {
        super.updateUI()
        filterLabel?.text = selectedTimeData?.title
        clvContent?.reloadData()
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
    
    func initVar()  {
        let dataManager = TimeData()
        if let _timeData = dataManager.getTimeDataItemDefault() {
            selectedTimeData = _timeData
        }else {
            selectedTimeData = dataManager.getTimeDataItemType(type: .TimeItemTypeToday)
            dataManager.setTimeDataItemDefault(item: selectedTimeData!)
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
                                                       timeData: selectedTimeData,
                                                       needHides: arrHide as [NSNumber]) {[weak self] (success, timeData) in
                                                        self?.selectedTimeData = timeData
                                                        self?.getListTask(timeDataItem: timeData, isFetch: true)
        }
    }
}


//MARK: - DMSNavigationServiceDelegate
extension TaskListVC:DMSNavigationServiceDelegate{
    func didSelectedMenuAction() {
        showSideMenu()
    }
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
        getListTask(timeDataItem:selectedTimeData! ,isFetch: true)
    }
    
    func getListTask(timeDataItem:TimeDataItem,isFetch:Bool = false) {
        if !isFetch {
            self.showLoadingIndicator()
        }
        SERVICES().API.getTaskList(self.selectedTimeData!) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.clvContent?.endRefreshControl()
            switch result{
            case .object(let obj):
                self?.taskList = obj.data?.data ?? []
                self?.taskList.sort(by: { (task1, task2) -> Bool in
                    return task1.id < task2.id
                })
                
                self?.lblNoData?.isHidden = self?.taskList.count > 0
                self?.updateUI()
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
                break
            }
        }
    }
}
