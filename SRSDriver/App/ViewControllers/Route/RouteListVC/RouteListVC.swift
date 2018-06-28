//
//  RouteListVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class RouteListVC: BaseViewController {
    
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var pickerContainerView: UIView!

    @IBOutlet weak var tbvContent:UITableView?
    @IBOutlet weak var lblNoResult:UILabel?

    
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
    
    override func updateNavigationBar() {
        setupNavigateBar()
    }
    
    func setupNavigateBar() {
        self.navigationService.delegate = self
        self.navigationService.updateNavigationBar(.Menu_Calenda, "Routes List")
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
        dataRows = [["Truck :", "\(route?.truckID ?? 0)"],
                    ["Total Orders :",""],
                    ["Distance :",""],
                    ["Job Date :", E(route?.date)]]
    }
    
    @IBAction func didChooseCalendar(_ sender: UIBarButtonItem) {
        let dateString = datePickerView.date.toString("yyyy-MM-dd")
        getRoutes(byDate: dateString)
        let height = Constants.toolbarHeight + Constants.pickerViewHeight;
        pickerContainerView.transform = CGAffineTransform(translationX: 0, y: -height)
        UIView.animate(withDuration: 0.25, animations: {
            self.pickerContainerView.transform = CGAffineTransform(translationX: 0, y: -height)
        }) { (isFinish) in
            self.pickerContainerView.isHidden = true
            self.pickerContainerView.transform = .identity
        }
    }
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
        let vc:RouteDetailVC = .loadSB(SB: .Route)
        if let routes = listRoutes {
            let route = routes[indexPath.section];
            vc.route = route;
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


//MARK: - API
fileprivate extension RouteListVC{
    
    func getRoutes(byDate date: String? = nil) {
        showLoadingIndicator()
        API().getRoutes(byDate: date) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            
            switch result{
            case .object(let obj):
                self?.listRoutes = obj.toArray()
                self?.lblNoResult?.isHidden = (self?.listRoutes?.count ?? 0 > 0)

            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}

extension RouteListVC:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        //
    }
    
    func didSelectedRightButton() {
        
        pickerContainerView.isHidden = false
        let height = Constants.toolbarHeight + Constants.pickerViewHeight;
        pickerContainerView.transform = CGAffineTransform(translationX: 0, y: height)
        UIView.animate(withDuration: 0.25) {
            self.pickerContainerView.transform = .identity
        }
    }
}
