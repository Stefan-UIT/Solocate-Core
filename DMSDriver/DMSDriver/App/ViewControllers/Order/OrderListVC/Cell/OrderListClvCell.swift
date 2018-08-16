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
    fileprivate let cellHeight: CGFloat = 150.0
    
    fileprivate var orderList:[Order] = []
    
    var tapDisplay:TapFilterOrderList = .All {
        didSet{
            filterDataWithTapDisplay()
        }
    }
    var dateStringFilter = ""
    
    var route: Route?
    var rootVC: BaseViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateUI()
    }
    
    func updateUI() {
        setupTableView()
        if let orderList = self.route?.orderList {
            noOrdersLabel?.isHidden = orderList.count > 0
        }
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderItemTableViewCell {
            
            let order = orderList[indexPath.row]
            order.storeName = E(route?.warehouse?.name)
            cell.order = order
            cell.btnNumber?.setTitle("\(indexPath.row + 1)", for: .normal)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard route != nil else { return }
        let movedOrder = route?.orderList[sourceIndexPath.row]
        route?.orderList.remove(at: sourceIndexPath.row)
        route?.orderList.insert(movedOrder!, at: destinationIndexPath.row)
        tableView.reloadData()
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
        
        if let order = route?.orderList[indexPath.row] {
            vc.order = order
            vc.routeID = route?.id
            vc.dateStringFilter = dateStringFilter
        }
        self.rootVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateStatusOrder(_ order:OrderDetail) {
        if (route?.orderList.contains{$0.id == order.id}) ?? false {
            if let _index = route?.orderList.index(where: {$0.id == order.id}){
                route?.orderList[_index].statusCode = order.statusCode
                route?.orderList[_index].statusName = order.statusName
            }
        }
        
        self.tableView.reloadData()
    }
    
    func filterDataWithTapDisplay() {
        switch tapDisplay {
        case .All:
            orderList = route?.orderList ?? []
        case .Assigned:
            orderList = route?.orderList.filter({ (order) -> Bool in
                return order.driver_id != Caches().user?.userID
            }) ?? []

        case .Mine:
            orderList = route?.orderList.filter({ (order) -> Bool in
                return order.driver_id == Caches().user?.userID
            }) ?? []
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
                self?.route = obj
                self?.filterDataWithTapDisplay()
            case .error(let error):
                self?.rootVC?.showAlertView(error.getMessage())
                
            }
        }
    }
}
