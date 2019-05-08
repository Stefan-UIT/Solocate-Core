//
//  RouteDetailLocationListClvCell.swift
//  DMSDriver
//
//  Created by Mach Van  Nguyen on 3/27/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import SVProgressHUD

class RouteDetailLocationListClvCell: UICollectionViewCell {
    
    @IBOutlet weak var tbvContent: UITableView?
    @IBOutlet weak var noOrdersLabel: UILabel?
    
    fileprivate let cellIdentifier = "LocationListTbvCell"

    fileprivate var locationsList:[Order] = []
    
    var dateStringFilter = ""
    var route: Route?
    var rootVC: BaseViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    }
}

// MARK: - Private methods

extension RouteDetailLocationListClvCell {
    func convertString(_ text: String, withFormat format: String = "yyyy-MM-dd") -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let date = dateFormater.date(from: text) ?? Date()
        dateFormater.dateFormat = format
        
        return dateFormater.string(from: date)
        
    }
}


//MARK: - RouteDetailOrderListClvCell,UITableViewDataSource
extension RouteDetailLocationListClvCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return route?.locationList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier ,
                                                    for: indexPath) as? LocationListTbvCell {
            let address = route?.locationList[indexPath.row]
            cell.address = address
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        tableView.deselectRow(at: indexPath, animated: true)
        let vc:OrderListViewController = .loadSB(SB: .Order)
        self.rootVC?.navigationController?.pushViewController(vc, animated: true)
         */
    }
}


//MARK: - API
extension RouteDetailLocationListClvCell{
    
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
                
                // Update route to DB local
            //CoreDataManager.updateRoute(obj.data!)
            case .error(let error):
                self?.rootVC?.showAlertView(error.getMessage())
                
            }
        }
    }
}
