//
//  PurchaseOrderListVC.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 12/16/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import SideMenu

class PurchaseOrderListVC: BaseViewController {

    @IBOutlet weak var tbvContent:UITableView?
    @IBOutlet weak var lblDate:UILabel!
    
    var timeData:TimeDataItem?
    var filterModel = FilterDataModel()
    var isFromDashboard = false
    var isFromFilter = false
    
    var isFetchInProgress = false
    var isInfiniteScrolling = false
    var order:[PurchaseOrder] = []
    var page:Int = 1
    var currentPage:Int = 1
    var totalPages:Int = 1
    var selectedTimeData:TimeDataItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        initVar()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromDashboard == false && isFromFilter == false{
            fetchData(isShowLoading: true)
        } else if isFromFilter {
            isFromFilter = false
        }
    }
    
    // MARK: - Setup View
    
    private func initUI() {
        let filterTimeData = filterModel.timeData
        let dateTitle = filterTimeData?.title ?? ""
        var dateString = ""
        if filterTimeData?.type == TimeItemType.TimeItemTypeToday || filterTimeData?.type == TimeItemType.TimeItemFromNow {
            dateString = ShortDateFormater.string(from: filterTimeData?.startDate ?? Date())
        } else if filterTimeData?.type == TimeItemType.TimeItemTypeAll {
            dateString = ""
        } else {
            dateString = ShortDateFormater.string(from: filterTimeData?.startDate ?? Date()) + " - " + ShortDateFormater.string(from: filterTimeData?.endDate ?? Date())
        }
        let date = "here-is-your-plan".localized
        lblDate?.text = date + " for " + dateTitle + " " + dateString
    }
    
    override func updateNavigationBar() {
        setupNavigateBar()
    }
    
    private func initVar() {
        if timeData == nil {
            let dataManager = TimeData()
            timeData = dataManager.getTimeDataItemType(type: .TimeItemFromNow)
            filterModel.timeData = timeData
            dataManager.setTimeDataItemDefault(item: filterModel.timeData!)
        }
    }
    
    func setupNavigateBar() {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Filter_Button, "".localized)
    }
    
    func setupTableView() {
        tbvContent?.delegate = self
        tbvContent?.dataSource = self
        tbvContent?.prefetchDataSource = self
        if isFromDashboard == false {
            tbvContent?.addRefreshControl(self, action: #selector(fetchData(isShowLoading:)))
        }
        //        tbvContent?.prefetchDataSource = self
        //        tbvContent?.addPullToRefetch(self, action: #selector(fetchData))
    }
    
    @objc func fetchData(isShowLoading:Bool = true)  {
        getRentingOrders(filterMode: filterModel, isShowLoading: isShowLoading, isFetch: true)
    }
    
    //    func updateRouteList(routeNeedUpdate:Route) {
    //        for (index,route) in self.routes.enumerated() {
    //            if route.id == routeNeedUpdate.id {
    //                self.routes[index] = routeNeedUpdate
    //                break
    //            }
    //        }
    //        tableView.reloadData()
    //    }
    
    
}


// MARK: - UICollectionViewDataSource
extension PurchaseOrderListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbvContent?.dequeueReusableCell(withIdentifier: "PurchaseOrderListTableViewCell", for: indexPath) as! PurchaseOrderListTableViewCell
        //        guard let _order = self.rentingOrder else { return UITableViewCell() }
        let _order = order[indexPath.row]
        cell.configureCell(_order)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

//MARK: - UICollectionViewDelegate
extension PurchaseOrderListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let vc:PurchaseOrderDetailVC = PurchaseOrderDetailVC.loadSB(SB: .PurchaseOrder)
        vc.order = order[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

private extension PurchaseOrderListVC {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row + 1 >= self.order.count
    }
}

extension PurchaseOrderListVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            if !(currentPage == totalPages) {
                self.isInfiniteScrolling = true
                self.fetchData()
            }
        }
    }
}

//MARK: - DMSNavigationServiceDelegate
extension PurchaseOrderListVC:DMSNavigationServiceDelegate {
    //    func didSelectedBackOrMenu() {
    //        showSideMenu()
    //    }
    
    func didSelectedAddButton(_ sender: UIBarButtonItem) {
        let vc:BusinessOrderDetailVC = PurchaseOrderDetailVC.loadSB(SB: .BusinessOrder)
        vc.order = BusinessOrder()
        vc.isEditingBO = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didSelectedMenuAction() {
        showSideMenu()
    }
    
    func didSelectedBackAction() {
        popViewController()
    }
    
    func didSelectedLeftButton(_ sender: UIBarButtonItem) {
        FilterDataListVC.show(atViewController: self, currentFilter: filterModel, filterScenceType: .PurchaseOrderListVC) {[weak self] (success, data) in
            guard let strongSelf = self,success == true else{
                return
            }
            strongSelf.filterModel = data
            strongSelf.initUI()
            strongSelf.fetchData(isShowLoading: true)
        }
        self.isFromFilter = true
    }
}

// MARK: -API
fileprivate extension PurchaseOrderListVC {
    
    func getRentingOrders(filterMode:FilterDataModel, isShowLoading:Bool = true, isFetch:Bool = false) {
        if ReachabilityManager.isNetworkAvailable {
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
                self.order = [PurchaseOrder]()
                tbvContent?.reloadData()
            }
            SERVICES().API.getPurchaseOrders(filterMode: filterMode, page: page) {[weak self] (result) in
                self?.dismissLoadingIndicator()
                self?.tbvContent?.endRefreshControl()
                guard let strongSelf = self else {
                    return
                }
                switch result{
                case .object(let obj):
                    if let data = obj.data?.data {
                        self?.totalPages = obj.data?.meta?.total_pages ?? 1
                        self?.currentPage = obj.data?.meta?.current_page ?? 1

                        if self?.currentPage != self?.totalPages {
                            self?.page = (self?.currentPage ?? 1) + 1
                        }
                        self?.order.append(data)
                        strongSelf.tbvContent?.reloadData()
                        self?.isFetchInProgress = false
                }
                case .error(let error):
                    self?.isFetchInProgress = false
                    strongSelf.showAlertView(error.getMessage())
                    
                }
            }
        } else {
            // CoreData
        }
    }
    
}

//MARK: - CoreData
fileprivate extension PurchaseOrderListVC {
//    func getRentingOrders() -> [RentingOrder] {
//        let results = CoreDataManager.getListRentingOrder()
//        return results
//    }
//
}

//MARK: - Filter Routes
fileprivate extension PurchaseOrderListVC {
//    func handleFilterRentingorder(with filterDataModel: FilterDataModel, rentingOrders: [RentingOrder]) -> [RentingOrder] {
//        var filterRentingOrders = [RentingOrder]()
//        let timeData = filterDataModel.timeData
//        let startDate = timeData?.startDate
//        let endDate = timeData?.endDate
//        let statusName = filterDataModel.status?.name
//        // Filter by Status
//        filterRentingOrders = (statusName == nil || statusName == "all-statuses".localized) ? rentingOrders : rentingOrders.filter({$0.rentingOrderStatus?.name == statusName})
//        // Filter by DateTime
//        filterRentingOrders = (startDate == nil && endDate == nil) ? filterRentingOrders : rentingOrders.filter({$0.startByDate >= startDate! && $0.endByDate <= endDate!})
//        return filterRentingOrders
//    }
}
