//
//  RouteListVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import SideMenu

class RouteListVC: BaseViewController {
    
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var pickerContainerView: UIView!

    @IBOutlet weak var tbvContent:UITableView?
    @IBOutlet weak var lblNoResult:UILabel?
    
    var dateStringFilter:String = Date().toString("yyyy-MM-dd")
    
    var listRoutes:[Route]?{
        didSet{
            tbvContent?.reloadData()
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
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
        self.tbvContent?.rowHeight = UITableViewAutomaticDimension
        self.tbvContent?.estimatedRowHeight = 100;
        
        self.tbvContent?.addRefreshControl(self, action: #selector(fetchData))
    }
  
    
    @IBAction func didChooseCalendar(_ sender: UIBarButtonItem) {
        dateStringFilter = datePickerView.date.toString("yyyy-MM-dd")
        getRoutes(byDate: dateStringFilter)
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listRoutes?.count ?? 0
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:RouteListCell = tableView.dequeueReusableCell(withIdentifier: "RouteListRowCell", for: indexPath) as! RouteListCell
        
        let row = indexPath.row
        if let routes = listRoutes {
            let route = routes[row]
          
           cell.lblTitle?.text = "Route ID-\(route.id)"
           cell.lblSubtitle?.text = E(route.date)
           cell.btnStatus?.setTitle(route.route_name_sts.localized, for: .normal)
           cell.btnColor?.backgroundColor = route.colorStatus
           cell.lblRouteNumber?.text = "\(route.route_number)";
           cell.lblTotal?.text = "\(route.totalOrders)"
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
            let route = routes[indexPath.row];
            vc.route = route;
            vc.dateStringFilter = dateStringFilter
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


//MARK: - API
fileprivate extension RouteListVC{
    
    @objc func fetchData() {
        getRoutes(byDate: dateStringFilter, isFetch: true)
    }
    
    func getRoutes(byDate date: String? = nil, isFetch:Bool = false) {
        if !isFetch {
            showLoadingIndicator()
        }
        API().getRoutes(byDate: date) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.tbvContent?.endRefreshControl()
            
            switch result{
            case .object(let obj):
                self?.listRoutes = obj.data
                self?.lblNoResult?.isHidden = (self?.listRoutes?.count ?? 0 > 0)

            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}

extension RouteListVC:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
      present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
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
