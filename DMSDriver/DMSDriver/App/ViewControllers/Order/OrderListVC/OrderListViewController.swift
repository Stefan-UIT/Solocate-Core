//
//  OrderListViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import SVProgressHUD
import FDFullscreenPopGesture

enum TapFilterOrderList:Int {
    case All = 0
    case New
    case InProgess
    case Finished
    case Cancelled
    
    var title:String{
        
        switch self {
        case .All:
            return "All".localized
        case .New:
            return "New".localized
        case .InProgess:
            return "in-progress".localized
        case .Finished:
            return "Finished".localized
        case .Cancelled:
            return "Cancelled".localized
        }
    }
    

}

enum DisplayMode:Int {
    case Reduced = 0
    case Expanded
    
}


class OrderListViewController: BaseViewController {
    
    @IBOutlet weak var tbvContent: UITableView?
    @IBOutlet weak var noOrdersLabel: UILabel?
    
    fileprivate let cellIdentifier = "OrderItemTableViewCell"
    fileprivate let cellReducedIdentifier = "OrderItemCollapseTableViewCell"
    
    var orderList:[Order] = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterDataWithTapDisplay()
        updateUI()
        tbvContent?.backgroundColor = UIColor.clear
    }
    
    override func updateNavigationBar() {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Menu, "List Orders".localized, AppColor.white, true)
    }
    
    
    override func updateUI() {
        super.updateUI()
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

extension OrderListViewController {
    func convertString(_ text: String, withFormat format: String = "yyyy-MM-dd") -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let date = dateFormater.date(from: text) ?? Date()
        dateFormater.dateFormat = format
        
        return dateFormater.string(from: date)
        
    }
}


//MARK: - RouteDetailOrderListClvCell,UITableViewDataSource
extension OrderListViewController: UITableViewDelegate, UITableViewDataSource {
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
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc:OrderDetailViewController = .loadSB(SB: .Order)
        vc.orderDetail = orderList[indexPath.row]
        self.rootVC?.navigationController?.pushViewController(vc, animated: true)
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
        self.tbvContent?.reloadData()
    }
}

//MARK: - DMSNavigationServiceDelegate
extension OrderListViewController:DMSNavigationServiceDelegate {
    func didSelectedBackOrMenu() {
        showSideMenu()
    }
}

//MARK: - API
extension OrderListViewController{
    
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
                
                // Update route to DB local
            //CoreDataManager.updateRoute(obj.data!)
            case .error(let error):
                self?.rootVC?.showAlertView(error.getMessage())
                
            }
        }
    }
}

