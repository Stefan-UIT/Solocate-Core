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
    
    @IBOutlet weak var menuScrollView:BaseScrollMenuView?
    @IBOutlet weak var conHeightViewSegment: NSLayoutConstraint?
    @IBOutlet weak var viewSegment: UIView?


    @IBOutlet weak var tbvContent:UITableView?
    @IBOutlet weak var lblNoResult:UILabel?
    
    // MARK: - Variables
    private var timer:Timer?
    private var apiCalling = false

    var dateStringFilter:String = Date().toString("MM/dd/yyyy")
    var dateFilter = Date()

    var tapDisplay:TapFilterRouteList = .All {
        didSet{
            reloadDataWithFilterMode(tapDisplay)
        }
    }
    
    var listRoutesOrigin:[Route] = []
    var listRoutes:[Route] = []{
        didSet{
            DispatchQueue.main.async {[weak self] in
                self?.tbvContent?.reloadData()
                self?.lblNoResult?.isHidden = (self?.listRoutes.count > 0)
            }
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupScrollMenuView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hasNetworkConnection {
            enableAutoRefetchRouteList()
            getDataFromServer()
        }else{
            getDataFromDBLocal(dateStringFilter)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endAutoRefetchRouteList()
    }
    
    override func reachabilityChangedNotification(_ notification: NSNotification) {
        super.reachabilityChangedNotification(notification)
        if hasNetworkConnection  {
            getDataFromServer()
            
        }else{
            endAutoRefetchRouteList()
            getDataFromDBLocal(dateStringFilter)
        }
    }
    
    override func updateNavigationBar() {
        setupNavigateBar()
    }
    
    deinit {
        endAutoRefetchRouteList()
    }
    
    func getDataFromDBLocal(_ stringDate:String) {
        CoreDataManager.queryRoutes(stringDate) { (success, routes) in
            if success{
                self.listRoutesOrigin = routes
                self.doSearchRoutes()
            }
        }
    }
    
    func enableAutoRefetchRouteList() {
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(DMSAppConfiguration.reloadRouteTimeInterval),
                                     target: self,
                                     selector: #selector(fetchData),
                                     userInfo: nil,
                                     repeats: true)

    }
    
    func endAutoRefetchRouteList() {
        timer?.invalidate()
        timer = nil
    }
    
    //MARK: - Intialize
    func setupScrollMenuView() {
        let all = MenuItem("All".localized)
        let asigned = MenuItem("Assigned".localized)
        let mine = MenuItem("Mine".localized)
        
        menuScrollView?.backgroundCell = AppColor.white
        menuScrollView?.selectedBackground = AppColor.mainColor
        menuScrollView?.cornerRadiusCell = 5
        menuScrollView?.dataSource = [all,asigned,mine]
        menuScrollView?.delegate = self
        if(Caches().user?.isCoordinator ?? false ||
            Caches().user?.isAdmin ?? false) {
            menuScrollView?.indexSelect = tapDisplay.rawValue
            conHeightViewSegment?.constant = 45
            menuScrollView?.isHidden = false
            
        }else{
            menuScrollView?.isHidden = true
            conHeightViewSegment?.constant = 0
        }
    }
    
    func setupNavigateBar() {
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Menu_Calenda, "Routes List".localized)
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
        /*
        self.listRoutes.removeAll()
        listRoutesOrigin.removeAll()
        switch filterMode{
        case .All:
            var addedArray = [Route]()
            if let coordinator:[Route] = coordinatorRoute?.coordinator{
                addedArray.append(coordinator)
            }
            
            if let drivers = coordinatorRoute?.drivers{
                addedArray.append(drivers)
            }
            self.listRoutesOrigin = addedArray
            
        case .Assigned:
            if let drivers = coordinatorRoute?.drivers{
                self.listRoutesOrigin = drivers
            }
        case .Mine:
            if let coordinator:[Route] = coordinatorRoute?.coordinator{
                self.listRoutesOrigin = coordinator
            }
        }
        
        self.doSearchRoutes()
         */
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
        
        let cell:RouteListCell = tableView.dequeueReusableCell(withIdentifier: "RouteListRowCell",
                                                               for: indexPath) as! RouteListCell
        let row = indexPath.row
        let route = listRoutes[row]
        let displayDateTimeVN = DateFormatter.displayDateTimeVN
        let displayDateVN = DateFormatter.displayDateVietNames
        let startTime = DateFormatter.serverDateFormater.date(from: route.start_time)
        let endTime = DateFormatter.serverDateFormater.date(from: route.end_time)
        let date = DateFormatter.displayDateUS.date(from: route.date)
        
        cell.lblTitle?.text = "\("Route".localized)ID-\(route.id)"
        cell.lblSubtitle?.text = (date != nil) ? displayDateVN.string(from: date!) : ""
        cell.btnStatus?.setTitle(route.nameStatus, for: .normal)
        cell.btnColor?.backgroundColor = route.colorStatus
        cell.lblRouteNumber?.text = "\(route.route_number)";
        cell.lblTotal?.text = "\(route.totalOrders)"
        cell.lblTruck?.text = route.truck?.name
        cell.lblTanker?.text = route.tanker?.name
        cell.lblStartTime?.text = (startTime != nil) ? displayDateTimeVN.string(from: startTime!) : ""
        cell.lblEndTime?.text = (endTime != nil) ? displayDateTimeVN.string(from: endTime!) : ""
        cell.selectionStyle = .none
        cell.csHeightActionView?.constant = (route.routeStatus == .New) ? 45 : 0
        cell.vAction?.isHidden = (route.routeStatus == .New) ? false :true
        cell.delegate = self
        
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
 
 //MARK: - RouteListCellDelegate
 extension RouteListVC :RouteListCellDelegate{
    func routeListCell(_ cell: RouteListCell, didSelectStartRoute button: UIButton) {
        guard let indexPath = tbvContent?.indexPath(for: cell) else {
            return
        }
        let route = listRoutes[indexPath.row]

        App().showAlertView("Do you want to start this route?".localized,
                            positiveTitle: "YES".localized,
                            positiveAction: {[weak self] (hasOK) in
                                self?.startRoute(route: route)
                                
        }, negativeTitle: "NO".localized) { (cancel) in
            return
        }
    }
 }


//MARK: - API
 extension RouteListVC{
    
    @objc func fetchData() {
        getDataFromServer(true)
    }
    
    func getDataFromServer(_ isFetch:Bool = false)  {
        /*
        let count = CoreDataManager.countRequestLocal()
        if count > 0 || apiCalling == true {
            return
        }
        apiCalling = true
         */
        
        print("Date Filter ==> \(dateStringFilter)")
        self.getRoutes(byDate: self.dateStringFilter, isFetch: isFetch)
    }
    
    fileprivate func getRoutes(byDate date: String? = nil, isFetch:Bool = false) {
        if !isFetch {
            showLoadingIndicator()
        }
        API().getRoutes(byDate: date) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.tbvContent?.endRefreshControl()
            self?.apiCalling = false

            switch result{
            case .object(let obj):
                if let _obj = obj.data?.data{
                    self?.listRoutesOrigin = _obj
                    self?.doSearchRoutes()
                    
                    /*
                    if _obj.count > 0{
                        
                        self?.listRoutesOrigin = _obj
                        self?.doSearchRoutes()
                        CoreDataManager.saveRoutes(_obj,
                                                   callback: {(success, routes)  in
                            if success{
                                print("Save route successfull")
                                //self?.getDataFromDBLocal(E(self?.dateStringFilter))
                            }
                        })
                    }else{
                        self?.listRoutes = _obj
                        CoreDataManager.deleteRoutes(E(self?.dateStringFilter),
                                                     onCompletion: { (success) in
                            print("Delete route success!")
                        })
                    }
                     */
                }
               
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    fileprivate func startRoute(route:Route) {
        self.showLoadingIndicator()
        SERVICES().API.startRoute("\(route.id)") {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_ ):
                self?.fetchData()
                Caches().dateStartRoute = Date.now
                
                let totalMinutes = Caches().drivingRule?.data ?? 0
                LocalNotification.createPushNotificationAfter(totalMinutes,
                                                              "Reminder".localized,
                                                              "Your task has been over.",
                                                              "remider.timeout.drivingrole",  [:])
            case .error(let error):
                self?.showAlertView(E(error.message))
            }
        }
    }
}
 
 
 //MARK: - BaseScrollMenuViewDelegate
 extension RouteListVC:BaseScrollMenuViewDelegate{
    
    func baseScrollMenuViewDidSelectAtIndexPath(_ view: BaseScrollMenuView, _ indexPath: IndexPath) {
        if let tapSelect = TapFilterRouteList(rawValue: indexPath.row){
            tapDisplay = tapSelect
        }
    }
 }
 

 //MARK: - DMSNavigationServiceDelegate
extension RouteListVC:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        if Constants.isLeftToRight {
            if let  menuLeft = SideMenuManager.default.menuLeftNavigationController{
                present(menuLeft, animated: true, completion: nil)
            }
        }else{
            if let menuRight = SideMenuManager.default.menuRightNavigationController{
                present(menuRight, animated: true, completion: nil)
            }
        }
    }
    
    func didSelectedRightButton() {
        let dateFormater =  DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"

        let currentDate = dateFormater.date(from: dateStringFilter)
        UIAlertController.showDatePicker(style: .actionSheet,
                                         mode: .date,
                                         title: "Select date".localized,
                                         currentDate: currentDate) {[weak self] (date) in
                                            
            self?.dateFilter = date
            self?.dateStringFilter = date.toString("yyyy-MM-dd")
            if self?.hasNetworkConnection ?? false{
                self?.getDataFromServer()
            }else{
                self?.getDataFromDBLocal(E(self?.dateStringFilter))
            }
        }
    }
}
 
 //MARK: - Other funtion
 extension RouteListVC{
    func doSearchRoutes() {
        self.listRoutes = self.listRoutesOrigin

        /*
        self.listRoutes = self.listRoutesOrigin.filter({ (route) -> Bool in
            route.updateStatusWhenOffline()
            return !(route.routeStatus == .Canceled ||
                    route.routeStatus == .Finished) //mobile: ẩn ruote finish cancelled đi
        })
         */
    }
 }
 

 

