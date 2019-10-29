//
//  RentingOrderListViewController.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 9/24/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import SideMenu

class RentingOrderListVC: BaseViewController {
    
    @IBOutlet weak var tbvContent:UITableView?
    var timeData:TimeDataItem?
    var filterModel = FilterDataModel()
    var isFromDashboard = false
    var isFromFilter = false
    
    var isFetchInProgress = false
    var isInfiniteScrolling = false
    var rentingOrders:[RentingOrder] = []
    var page:Int = 1
    var currentPage:Int = 1
    var totalPages:Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromDashboard == false && isFromFilter == false{
            fetchData(isShowLoading: true)
        } else if isFromFilter {
            isFromFilter = false
        }
    }
    
    override func updateNavigationBar() {
        setupNavigateBar()
    }
    
    private func initVar() {
        if timeData == nil {
            let dataManager = TimeData()
            timeData = dataManager.getTimeDataItemType(type: .TimeItemTypeToday)
            filterModel.timeData = timeData
            dataManager.setTimeDataItemDefault(item: filterModel.timeData!)
        }
    }
    
    func setupNavigateBar() {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Filter_Menu, "".localized)
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
        getRoutes(filterMode: filterModel, isShowLoading: isShowLoading, isFetch: true)
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
extension RentingOrderListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rentingOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbvContent?.dequeueReusableCell(withIdentifier: "RentingOrderListTableViewCell", for: indexPath) as! RentingOrderListTableViewCell
//        guard let _order = self.rentingOrder else { return UITableViewCell() }
        let order = rentingOrders[indexPath.row]
        cell.configureCellWithRentingOrder(order)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

//MARK: - UICollectionViewDelegate
extension RentingOrderListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let vc:RentingOrderDetailVC = RentingOrderDetailVC.loadSB(SB: .RentingOrder)
        vc.rentingOrder = rentingOrders[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

private extension RentingOrderListVC {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row + 1 >= self.rentingOrders.count
    }
}

extension RentingOrderListVC: UITableViewDataSourcePrefetching {
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
extension RentingOrderListVC:DMSNavigationServiceDelegate {
    //    func didSelectedBackOrMenu() {
    //        showSideMenu()
    //    }
    
    func didSelectedMenuAction() {
        showSideMenu()
    }
    
    func didSelectedBackAction() {
        popViewController()
    }
    
    func didSelectedLeftButton(_ sender: UIBarButtonItem) {
        FilterDataListVC.show(atViewController: self, currentFilter: filterModel, filterScenceType: .RentingOrderListVC) {[weak self] (success, data) in
            guard let strongSelf = self,success == true else{
                return
            }
            strongSelf.filterModel = data
            strongSelf.fetchData(isShowLoading: true)
        }
        self.isFromFilter = true
    }
}

// MARK: -API
fileprivate extension RentingOrderListVC {
    func getRoutes(filterMode:FilterDataModel, isShowLoading:Bool = true, isFetch:Bool = false) {
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
            self.rentingOrders = [RentingOrder]()
            tbvContent?.reloadData()
        }
        
        
        SERVICES().API.getRentingOrders(filterMode: filterMode, page: page) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.tbvContent?.endRefreshControl()
            guard let strongSelf = self else {
                return
            }
            switch result{
            case .object(let obj):
                if let data = obj.data?.data {
//                    strongSelf.rentingOrders = data
                    // DMSCurrentRoutes.routes = data
//                    strongSelf.lblNoResult?.isHidden = (strongSelf.routes.count > 0)
                    self?.totalPages = obj.data?.meta?.total_pages ?? 1
                    self?.currentPage = obj.data?.meta?.current_page ?? 1
                    
                    if self?.currentPage != self?.totalPages {
                        self?.page = (self?.currentPage ?? 1) + 1
                    }
                    self?.rentingOrders.append(data)
                    strongSelf.tbvContent?.reloadData()
                    self?.isFetchInProgress = false
                    
                } else {
                    // TODO: Do something.
                }
                
            case .error(let error):
                strongSelf.showAlertView(error.getMessage())
                self?.isFetchInProgress = false
                break
            }
        }
    }
    
}
