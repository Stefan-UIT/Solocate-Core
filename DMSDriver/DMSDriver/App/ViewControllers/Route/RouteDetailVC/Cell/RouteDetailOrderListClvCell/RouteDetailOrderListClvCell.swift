//
//  RouteDetailOrderListClvCell.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 3/14/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import SVProgressHUD


class RouteDetailOrderListClvCell: UICollectionViewCell {
    
    @IBOutlet weak var tbvContent: UITableView?
    @IBOutlet weak var noOrdersLabel: UILabel?
    
    fileprivate let cellIdentifier = "OrderItemTableViewCell"
    fileprivate let cellReducedIdentifier = "OrderItemCollapseTableViewCell"
    
    fileprivate var orderList:[Order] = []
    
    var filterOrderList:TapFilterOrderList = .All {
        didSet{
            self.filterDataWithTapDisplay()
        }
    }
    
    var displayMode:DisplayMode = DisplayMode.Expanded {
        didSet{
            tbvContent?.reloadData()
        }
    }
    
    var route: Route? {
        didSet{
            filterDataWithTapDisplay()
        }
    }
    var rootVC: BaseViewController?
    var dateStringFilter = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        filterDataWithTapDisplay()
        updateUI()
        tbvContent?.backgroundColor = UIColor.clear
    }
    
    func updateUI() {
        setupTableView()
    }
    
    func setupTableView() {
        tbvContent?.delegate = self
        tbvContent?.dataSource = self
        tbvContent?.addRefreshControl(self, action: #selector(fetchData))
    }
    
    //MARK: -Action
    @IBAction func onbtnClickSwitchMode(btn:UIButton){
        btn.isSelected = !btn.isSelected
        if displayMode == .Expanded {
            displayMode = .Reduced
        }else{
            displayMode = .Expanded
        }
    }
}

// MARK: - Private methods

extension RouteDetailOrderListClvCell {
    func convertString(_ text: String, withFormat format: String = "yyyy-MM-dd") -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let date = dateFormater.date(from: text) ?? Date()
        dateFormater.dateFormat = format
        
        return dateFormater.string(from: date)
        
    }
}


//MARK: - RouteDetailOrderListClvCell,UITableViewDataSource
extension RouteDetailOrderListClvCell: UITableViewDelegate, UITableViewDataSource {
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
            let seq = indexPath.row + 1
            cell.lblNumber?.text = "\(seq)."
     
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc:OrderDetailViewController = .loadSB(SB: .Order)
        vc.route = route
        vc.orderDetail = orderList[indexPath.row]
        vc.updateOrderDetail = {[weak self](order) in
            self?.fetchData()
        }
        self.rootVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func reloadOrderListScreen(route:Route) {
        let viewControllers = App().mainVC?.rootNV?.viewControllers ?? []
        for (_,viewController) in viewControllers.enumerated() {
            if let routeListVC = viewController as? RouteListVC {
                routeListVC.updateRouteList(routeNeedUpdate: route)
                break
            }
        }
    }
    
    func updateStatusOrder(_ order:Order) {
        if (orderList.contains{$0.id == order.id}) {
            if let _index = orderList.index(where: {$0.id == order.id}){
                orderList[_index].statusCode = order.statusCode
                orderList[_index].statusName = order.statusName
            }
        }
        
        self.tbvContent?.reloadData()
    }
    
    func filterDataWithTapDisplay() {
        guard let _route = route else { return }
//        switch filterOrderList {
//        case .All:
//            orderList = route?.getOrderList() ?? []
//        case .New:
//            orderList = route?.orders(.newStatus) ?? []
//        case .InProgess:
//            orderList = route?.orders(.InTransit) ?? []
//        case .Finished:
//            orderList = route?.orders(.deliveryStatus) ?? []
//        case .Cancelled:
//            orderList = route?.orders(.CancelStatus) ?? []
//        }
        
//        orderList.sort { (ord1, ord2) -> Bool in
//            return ord1.seq < ord2.seq
//        }
        
        orderList = _route.ordersGroupByCustomer
        noOrdersLabel?.isHidden = orderList.count > 0
        self.tbvContent?.reloadData()
    }
}


//MARK: - API
extension RouteDetailOrderListClvCell{
    
    @objc func fetchData()  {
        if let route = self.route {
            getRouteDetail("\(route.id)", isFetch: true)
        }
    }
    
    func getRouteDetail(_ routeID:String, isFetch:Bool = false) {
        if !isFetch {
            self.rootVC?.showLoadingIndicator()
        }
        SERVICES().API.getRouteDetail(route: routeID) {[weak self] (result) in
            self?.rootVC?.dismissLoadingIndicator()
            self?.tbvContent?.endRefreshControl()
            
            switch result{
            case .object(let obj):
                self?.route = obj.data
                self?.filterDataWithTapDisplay()
                guard let _route = obj.data else {return}
                self?.reloadOrderListScreen(route: _route)
                
                // Update route to DB local
            //CoreDataManager.updateRoute(obj.data!)
            case .error(let error):
                self?.rootVC?.showAlertView(error.getMessage())
                
            }
        }
    }
}

