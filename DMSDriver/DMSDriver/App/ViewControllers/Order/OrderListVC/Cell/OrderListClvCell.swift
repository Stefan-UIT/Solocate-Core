//
//  OrderListClvCell.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 8/14/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit

class OrderListClvCell: UICollectionViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noOrdersLabel: UILabel?
    
    fileprivate let cellIdentifier = "OrderItemTableViewCell"
    fileprivate let cellReducedIdentifier = "OrderItemCollapseTableViewCell"
    
    fileprivate var orderList:[Order] = []
    
    var filterOrderList:TapFilterOrderList = .All {
        didSet{
            self.filterDataWithTapDisplay()
        }
    }
    
    var displayMode:DisplayMode = DisplayMode.Reduced
    var dateStringFilter = ""
    var route: Route?
    var rootVC: BaseViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }
    
    func updateUI() {
        setupTableView()
    }
    
    func setupTableView() {
        tableView.addRefreshControl(self, action: #selector(fetchData))
    }
}

// MARK: - Private methods

extension OrderListClvCell {
    func convertString(_ text: String, withFormat format: String = "yyyy-MM-dd") -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let date = dateFormater.date(from: text) ?? Date()
        dateFormater.dateFormat = format
        
        return dateFormater.string(from: date)
        
    }
}


//MARK: - UITableViewDelegate,UITableViewDataSource
extension OrderListClvCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderList.count
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: displayMode == .Reduced ? cellReducedIdentifier : cellIdentifier,
                                                    for: indexPath) as? OrderItemTableViewCell {
            
            let order = orderList[indexPath.row]
            cell.order = order
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc:OrderDetailContainerViewController = .loadSB(SB: .Order)
        
        vc.onUpdateOrderStatus = {[weak self]  (order)  in
            self?.updateStatusOrder(order)
        }
        
        let order = orderList[indexPath.row]
        vc.order = order
        vc.route = route
        vc.dateStringFilter = dateStringFilter

        self.rootVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateStatusOrder(_ order:Order) {
        if (orderList.contains{$0.id == order.id}) {
            if let _index = orderList.index(where: {$0.id == order.id}){
                orderList[_index].statusCode = order.statusCode
                orderList[_index].statusName = order.statusName
            }
        }
        
        self.tableView.reloadData()
    }
    
    func filterDataWithTapDisplay() {
        switch filterOrderList {
        case .All:
            orderList = route?.getOrderList() ?? []
        case .New:
            orderList = route?.orders(.newStatus) ?? []
        case .InProgess:
            orderList = route?.orders(.inProcessStatus) ?? []
        case .Finished:
            orderList = route?.orders(.deliveryStatus) ?? []
        case .Cancelled:
            orderList = route?.orders(.cancelStatus) ?? []
        }
        
        orderList.sort { (ord1, ord2) -> Bool in
            return ord1.seq < ord2.seq
        }
        noOrdersLabel?.isHidden = orderList.count > 0
        self.tableView.reloadData()
    }
}


//MARK: - API
extension OrderListClvCell{
    
    @objc func fetchData()  {
        if let route = self.route {
            getRouteDetail("\(route.id)", isFetch: true)
        }
    }
    
    func getRouteDetail(_ routeID:String, isFetch:Bool = false) {
        if !isFetch {
            self.rootVC?.showLoadingIndicator()
        }
        API().getRouteDetail(route: routeID) {[weak self] (result) in
            self?.rootVC?.dismissLoadingIndicator()
            self?.tableView.endRefreshControl()
            
            switch result{
            case .object(let obj):
                self?.route = obj.data
                self?.filterDataWithTapDisplay()
                
                // Update route to DB local
                CoreDataManager.updateRoute(obj.data!)
            case .error(let error):
                self?.rootVC?.showAlertView(error.getMessage())
                
            }
        }
    }
}
