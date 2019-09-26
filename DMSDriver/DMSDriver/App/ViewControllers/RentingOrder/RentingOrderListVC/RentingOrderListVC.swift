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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hardCodeDemo()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        fetchData()
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
    
    func setupNavigateBar() {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Menu, "".localized)
    }
    
    func setupTableView() {
        tbvContent?.delegate = self
        tbvContent?.dataSource = self
//        tbvContent?.prefetchDataSource = self
//        tbvContent?.addPullToRefetch(self, action: #selector(fetchData))
    }
    
    
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
extension RentingOrderListVC:DMSNavigationServiceDelegate{
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
