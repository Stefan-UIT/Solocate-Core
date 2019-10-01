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
    var rentingOrder = [RentingOrder]()
    var timeData:TimeDataItem?
//    var routes = [Route]()
    var orders = [Order]()
    var filterModel = FilterDataModel()
    var isFromDashboard = false
    var isFromFilter = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hardCodeDemo()
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
    
    func hardCodeDemo() {
        
        
        let rentingOrder1 = RentingOrder()
        rentingOrder1.customerName = "ABC"
        rentingOrder1.endDate = "04:00 AM"
        rentingOrder1.startDate = "05:00 AM"
        rentingOrder1.refCode = 123123
        rentingOrder1.rentingOrderId = 123
        rentingOrder1.rentingStatus = StatusRentingOrder(rawValue: "OP")
        rentingOrder1.truckType?.name = "Car"
        rentingOrder1.trailerTankerType = "Super X"
        
        let a = ["Fish", "Dog", "Cat", "Oil", "Gas"]
        for index in 0..<a.count {
            let sample = Order.Detail()
            sample.name = a[index]
            rentingOrder1.skus.append(sample)
        }
        
        let rentingOrder2 = RentingOrder()
        rentingOrder2.customerName = "ABC ZSY AAS ASD DDDS SSSA SSS PPP SKKK "
        rentingOrder2.endDate = "04:00 PM"
        rentingOrder2.startDate = "05:00 PM"
        rentingOrder2.refCode = 34
        rentingOrder2.rentingOrderId = 13
        rentingOrder2.rentingStatus = StatusRentingOrder(rawValue: "IP")
        rentingOrder2.truckType?.name = "Bike"
        rentingOrder2.trailerTankerType = "Super Ben"
        
        let b = ["Shark", "Dog", "Cat", "Oil", "Gas"]
        for index in 0..<b.count {
            let sample = Order.Detail()
            sample.name = b[index]
            rentingOrder2.skus.append(sample)
        }
        
        rentingOrder.append(rentingOrder1)
        rentingOrder.append(rentingOrder2)
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
        if isFromDashboard == false {
            tbvContent?.addRefreshControl(self, action: #selector(fetchData(isShowLoading:)))
        }
//        tbvContent?.prefetchDataSource = self
//        tbvContent?.addPullToRefetch(self, action: #selector(fetchData))
    }
    
    @objc func fetchData(isShowLoading:Bool = true)  {
//        getRoutes(filterMode: filterModel, isShowLoading: isShowLoading)
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
        return rentingOrder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbvContent?.dequeueReusableCell(withIdentifier: "RentingOrderListTableViewCell", for: indexPath) as! RentingOrderListTableViewCell
//        guard let _order = self.rentingOrder else { return UITableViewCell() }
        let order = rentingOrder[indexPath.row]
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
        vc.rentingOrder = rentingOrder[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension RentingOrderListVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        //
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
        FilterDataListVC.show(atViewController: self,currentFilter: filterModel) {[weak self] (success, data) in
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
    func getOrders(filterMode: FilterDataModel, isShowLoading:Bool = true) {
        if isShowLoading {
            showLoadingIndicator()
        }
        
        
        ////
    }
}
