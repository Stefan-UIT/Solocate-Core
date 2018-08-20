//
//  RouteListVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import SideMenu

enum TapFilterRouteList:Int {
    case All = 0
    case Assigned
    case Mine
}

class RouteListVC: BaseViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl?
    @IBOutlet weak var conHeightViewSegment: NSLayoutConstraint?

    @IBOutlet weak var tbvContent:UITableView?
    @IBOutlet weak var lblNoResult:UILabel?
    
    // MARK: - Variables
    private var timer = Timer()
    private var backgroundTaskIdentifier = UIBackgroundTaskIdentifier()

    var dateStringFilter:String = Date().toString("yyyy-MM-dd")
    var dateFilter = Date()
    
    var coordinatorRoute:CoordinatorRouteModel?

    var tapDisplay:TapFilterRouteList = .All {
        didSet{
            reloadDataWithFilterMode(tapDisplay)
        }
    }
    
    var listRoutes:[Route] = []{
        didSet{
            tbvContent?.reloadData()
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        autoRefetchRouteList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        invalidTimer()
    }
    
    func autoRefetchRouteList() {
        invalidTimer()
        
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "seldat.com.directmail.routelist", expirationHandler: {
            //
        })
        
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(DMSAppConfiguration.reloadRouteTimeInterval),
                                     target: self,
                                     selector: #selector(fetchData),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func invalidTimer() {
        timer.invalidate()
        UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
    }
    
    override func reachabilityChangedNotification(_ notification: NSNotification) {
        super.reachabilityChangedNotification(notification)
        
        if hasNetworkConnection  {
            fetchData()
        }
    }
    
    override func updateNavigationBar() {
        setupNavigateBar()
    }
    
    //MARK: - Intialize
    func setupSegmentControl() {
        segmentControl?.segmentTitles = ["All".localized,
                                         "Assigned".localized,
                                         "Mine".localized]
        
        if(Caches().user?.isCoordinator ?? false ||
            Caches().user?.isAdmin ?? false) {
            segmentControl?.selectedSegmentIndex = 0
            conHeightViewSegment?.constant = 60
            
        }else{
            conHeightViewSegment?.constant = 0
        }
    }
    
    func updateUI()  {
        setupTableView()
        setupSegmentControl()
    }
    
    func setupNavigateBar() {
        self.navigationService.delegate = self
        self.navigationService.updateNavigationBar(.Menu_Calenda, "Routes List".localized)
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
    
    func reloadDataWithFilterMode(_ filterMode: TapFilterRouteList) {
        self.listRoutes.removeAll()
        switch filterMode{
        case .All:
            var addedArray = [Route]()
            if let coordinator:[Route] = coordinatorRoute?.coordinator{
                addedArray.append(coordinator)
            }
            
            if let driversdrivers = coordinatorRoute?.drivers{
                addedArray.append(driversdrivers)
            }
            self.listRoutes = addedArray
            
        case .Assigned:
            if let driversdrivers = coordinatorRoute?.drivers{
                self.listRoutes = driversdrivers
            }
        case .Mine:
            if let coordinator:[Route] = coordinatorRoute?.coordinator{
                self.listRoutes = coordinator
            }
        }
        
        self.lblNoResult?.isHidden = (self.listRoutes.count > 0)
        self.tbvContent?.reloadData()
    }
    
    //MARK: - Action
    @IBAction func onbtnClickSegment(segment:UISegmentedControl){
        if let tapSelect = TapFilterRouteList(rawValue: segment.selectedSegmentIndex){
            tapDisplay = tapSelect
        }
        //scrollToPageSelected(segment.selectedSegmentIndex)
    }
}

//MARK: - UITableViewDataSource
extension RouteListVC: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listRoutes.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:RouteListCell = tableView.dequeueReusableCell(withIdentifier: "RouteListRowCell", for: indexPath) as! RouteListCell
        
        let row = indexPath.row
        let route = listRoutes[row]
        
        cell.lblTitle?.text = "\("Route".localized)ID-\(route.id)"
        cell.lblSubtitle?.text = E(route.date)
        cell.btnStatus?.setTitle(route.nameStatus, for: .normal)
        cell.btnColor?.backgroundColor = route.colorStatus
        cell.lblRouteNumber?.text = "\(route.route_number)";
        cell.lblTotal?.text = "\(route.totalOrders)"
        cell.lblWarehouse?.text = route.shop_name
        cell.lblStartTime?.text = route.startDate
        cell.lblEndTime?.text = route.endDate
        cell.lblDriver?.text = route.driver_name
        cell.selectionStyle = .none
        return cell
    }
}


//MARK: - UITableViewDelegate
extension RouteListVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc:RouteDetailVC = .loadSB(SB: .Route)
        let route = listRoutes[indexPath.row];
        vc.route = route;
        vc.dateStringFilter = dateStringFilter
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


//MARK: - API
fileprivate extension RouteListVC{
    
    @objc func fetchData(isFetch:Bool = true) {
        if Caches().user?.isCoordinator ?? false ||
            Caches().user?.isAdmin ?? false {
            getRoutesByCoordinator(isFetch: isFetch)
        }else {
            getRoutes(byDate: dateStringFilter, isFetch: isFetch)
        }
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
                if let _obj = obj.data{
                    self?.listRoutes = _obj
                }
                self?.lblNoResult?.isHidden = (self?.listRoutes.count > 0)

            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    func getRoutesByCoordinator(isFetch:Bool = false) {
        if !isFetch {
            showLoadingIndicator()
        }
        
        API().getRoutesByCoordinator(byDate: dateStringFilter) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.tbvContent?.endRefreshControl()
            guard let strongSelf =  self else {return}
            switch result{
            case .object(let obj):
                strongSelf.coordinatorRoute = obj.data
                strongSelf.reloadDataWithFilterMode(strongSelf.tapDisplay)
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}

extension RouteListVC:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        if Constants.isLeftToRight {
            present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
        }else{
            present(SideMenuManager.default.menuRightNavigationController!, animated: true, completion: nil)
        }
    }
    
    func didSelectedRightButton() {
        
        UIAlertController.showDatePicker(style: .actionSheet,
                                         mode: .date,
                                         title: "Select date",
                                         currentDate: dateFilter) {[weak self] (date) in
                                            
            self?.dateFilter = date
            self?.dateStringFilter = date.toString("yyyy-MM-dd")
            self?.fetchData(isFetch: false)
                                    
        }
    }
}
