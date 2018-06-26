//
//  RouteListVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class RouteListVC: BaseViewController {
    
    @IBOutlet weak var tbvContent:UITableView?
    
    var listRoutes:[Route]?{
        didSet{
            tbvContent?.reloadData()
        }
    }
    
    var dataRows:[[String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        updateDataRows()
        getRoutes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        self.tbvContent?.delegate = self
        self.tbvContent?.dataSource = self
        self.tbvContent?.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tbvContent?.rowHeight = UITableViewAutomaticDimension
        self.tbvContent?.estimatedSectionHeaderHeight = 100;
        self.tbvContent?.estimatedRowHeight = 100;
    }
    
    func updateDataRows(_ route:Route? = nil) {
        dataRows.removeAll()
        dataRows = [["Truck", "\(String(describing: route?.truckID))"],
                    ["Total Orders",""],
                    ["Distance",""],
                    ["Job Date", E(route?.date)]]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - UITableViewDataSource
extension RouteListVC: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return listRoutes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataRows.count
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell:RouteListCell = tableView.dequeueReusableCell(withIdentifier: "RouteListHeaderCell") as! RouteListCell
        
        if let routes = listRoutes {
            let route = routes[section]
            headerCell.lblTitle?.text = "Route ID-\(route.id)"
        }
        
        return headerCell;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:RouteListCell = tableView.dequeueReusableCell(withIdentifier: "RouteListRowCell", for: indexPath) as! RouteListCell
        
        let row = indexPath.row
        let section = indexPath.section

        if let routes = listRoutes {
            let route = routes[section]
            
            self.updateDataRows(route)

            cell.lblTitle?.text = dataRows[row].first
            cell.lblSubtitle?.text = dataRows[row].last
        }
        cell.selectionStyle = .none
        return cell
    }
    
}


//MARK: - UITableViewDelegate
extension RouteListVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
}


//MARK: - API
fileprivate extension RouteListVC{
    
    func getRoutes(byDate date: String? = nil) {
        showLoadingIndicator()
        API().getRoutes() {[weak self] (result) in
            self?.dismissLoadingIndicator()
            
            switch result{
            case .object(let obj):
                self?.listRoutes = [obj]
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}
