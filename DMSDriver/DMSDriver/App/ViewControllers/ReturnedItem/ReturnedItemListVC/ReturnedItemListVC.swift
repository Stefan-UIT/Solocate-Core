//
//  TaskListVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 10/22/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import SideMenu

class ReturnedItemsListVC: BaseViewController {
    
    @IBOutlet weak var clvContent:UICollectionView?
    @IBOutlet weak var lblNoData: UILabel?

    @IBOutlet weak var filterLabel: UILabel!
    var timeData:TimeDataItem?
    
    fileprivate let taskListIdebtifierCell = "TaskListClvCell"
    
    var dateStringFilter:String = Date().toString("MM/dd/yyyy")
    var dateFilter = Date()
    var isFetchInProgress = false
    var isInfiniteScrolling = false
    var items:[ReturnedItem] = []
    var page:Int = 1
    var currentPage:Int = 1
    var totalPages:Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        initVar()
        updateUI()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    override func updateNavigationBar() {
        setupNavigateBar()
    }
    
    override func updateUI()  {
        super.updateUI()
        filterLabel?.text = timeData?.title
        clvContent?.reloadData()
    }
    
    
    override func reachabilityChangedNetwork(_ isAvailaibleNetwork: Bool) {
        super.reachabilityChangedNetwork(isAvailaibleNetwork)
        if isAvailaibleNetwork {
            fetchData()
        }else{
            
            DispatchQueue.main.async {[weak self] in
                self?.items = []
                self?.clvContent?.reloadData()
            }
        }
    }
    
    func initVar()  {
        if let _timeData = TimeData.getTimeDataItemDefault() {
            timeData = _timeData
        }else {
            timeData = TimeData.getTimeDataItemType(type: .TimeItemTypeToday)
            TimeData.setTimeDataItemDefault(item: timeData!)
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
        clvContent?.prefetchDataSource = self
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
                                                        self?.timeData = timeData
                                                        self?.getReturnedItems(timeDataItem: timeData, isFetch: true)
        }
    }
}


//MARK: - DMSNavigationServiceDelegate
extension ReturnedItemsListVC:DMSNavigationServiceDelegate{
    func didSelectedMenuAction() {
        showSideMenu()
    }
    /*
    func didSelectedLeftButton(_ sender: UIBarButtonItem) {
        let dateFormater =  DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        
        let currentDate = dateFormater.date(from: dateStringFilter)
        UIAlertController.showDatePicker(style: .actionSheet,
                                         mode: .date,
                                         title: "select-date".localized,
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
extension ReturnedItemsListVC:UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.size.width, height: 311)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReturnedItemListClvCell", for: indexPath) as! ReturnedItemListClvCell
        
        cell.item = items[indexPath.row]
        cell.btnNumber?.setTitle("\(indexPath.row + 1)", for: .normal)
        
        return cell
    }
}


//MARK: - UICollectionViewDelegate
extension ReturnedItemsListVC:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc: ReturnedItemDetailVC = .loadSB(SB: .ReturnedItem)
        vc.item = items[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - ScrollViewDelegate

private extension ReturnedItemsListVC {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.item+1 >= self.items.count
    }
}

extension ReturnedItemsListVC: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            if !(currentPage == totalPages) {
                self.isInfiniteScrolling = true
                self.fetchData()
            }
        }
    }
}


//MARK - API
extension ReturnedItemsListVC{
    
    @objc func fetchData()  {
        getReturnedItems(timeDataItem:timeData! ,isFetch: true)
    }
    
    func getReturnedItems(timeDataItem:TimeDataItem,isFetch:Bool = false) {
        guard !isFetchInProgress else {
            return
        }
        isFetchInProgress = true
        
        if isFetch {
            self.showLoadingIndicator()
        }
        
        if isInfiniteScrolling {
            self.isInfiniteScrolling = false
        } else {
            self.page = 1
            self.items = [ReturnedItem]()
            clvContent?.reloadData()
        }
        
        SERVICES().API.getReturnedItems(self.timeData!,page: page) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.clvContent?.endRefreshControl()
            switch result{
            case .object(let obj):
//                let taskList = obj.data?.data ?? []
//                let array = taskList.map({$0.toReturnedItems()})
//                self?.items = array
                self?.totalPages = obj.data?.meta?.total_pages ?? 1
                self?.currentPage = obj.data?.meta?.current_page ?? 1
                
                if self?.currentPage != self?.totalPages {
                    self?.page = (self?.currentPage ?? 1) + 1
                }
                
                self?.items.append(obj.data?.data ?? [])
                
//                self?.taskList.sort(by: { (task1, task2) -> Bool in
//                    return task1.id < task2.id
//                })
                
                self?.lblNoData?.isHidden = self?.items.count > 0
                self?.updateUI()
                self?.isFetchInProgress = false
            case .error(let error):
                self?.showAlertView(error.getMessage())
                self?.isFetchInProgress = false
                break
            }
        }
    }
}
