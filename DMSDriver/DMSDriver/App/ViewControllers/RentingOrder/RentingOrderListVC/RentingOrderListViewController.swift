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
    var rentingOrder: [RentingOrder]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        hardCodeDemo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        fetchData()
    }
    
    func hardCodeDemo() {
        let rentingOrder1 = RentingOrder()
        rentingOrder1.customerName = "ABC"
        rentingOrder1.endDate = "04:00 AM"
        rentingOrder1.startDate = "05:00 AM"
        rentingOrder1.refCode = 123123
        rentingOrder1.rentingOrderId = 123
        rentingOrder1.status = "NEW"
        rentingOrder1.truckType?.name = "Car"
        
        let rentingOrder2 = RentingOrder()
        rentingOrder2.customerName = "ABC ZSY AAS ASD DDDS SSSA SSS PPP SKKK KSLLL LLLA SS AAAAA OSSSSOO OOO SS"
        rentingOrder2.endDate = "04:00 PM"
        rentingOrder2.startDate = "05:00 PM"
        rentingOrder2.refCode = 34
        rentingOrder2.rentingOrderId = 13
        rentingOrder2.status = "FINISHED"
        rentingOrder2.truckType?.name = "Bike"
        
        rentingOrder?.append(rentingOrder1)
        rentingOrder?.append(rentingOrder2)
    }
    
    func setupCollectionView() {
        tbvContent?.delegate = self
        tbvContent?.dataSource = self
        tbvContent?.prefetchDataSource = self
        tbvContent?.estimatedRowHeight = 171.0
        tbvContent?.rowHeight = UITableView.automaticDimension
//        tbvContent?.addPullToRefetch(self, action: #selector(fetchData))
    }
    
    
}


// MARK: - UICollectionViewDataSource
extension RentingOrderListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbvContent?.dequeueReusableCell(withIdentifier: "RentingOrderListTableViewCell", for: indexPath) as! RentingOrderListTableViewCell
        guard let _order = self.rentingOrder else { return UITableViewCell() }
        cell.configureCellWithRentingOrder(_order[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

//MARK: - UICollectionViewDelegate
extension RentingOrderListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("")
    }
}

extension RentingOrderListVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        //
    }
    
    
}
