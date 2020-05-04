//
//  RouteDetailVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import Foundation
import SideMenu
import Floaty

enum TabBarItem:Int {
    case Order = 0
    case Packages;
    case Map;
    case Messages;
    
    func title() -> String {
        switch self {
        case .Order:
            return "orders-list".localized
        case .Packages:
            return "Packgages".localized
        case .Map :
            return "Map".localized
        case .Messages:
            return "Messanges".localized
        }
    }
}

enum RouteDetailDisplayMode:Int,CaseIterable {
    case DisplayModeMap = 0
    case DisplayModeStops
    case DisplayModeLocations
    case DisplayLoadPlan
    
    static var count: Int {
        return RouteDetailDisplayMode.DisplayModeLocations.hashValue + 1
    }
}

class RouteDetailVC: BaseViewController {
    
    @IBOutlet weak var assignDriverButtonView: UIView!
    
    @IBOutlet weak var assignTruckButtonView: UIView!
    //MARK: - IBOUTLET
    @IBOutlet weak var menuScrollView:BaseScrollMenuView?
    @IBOutlet weak var clvContent:UICollectionView?
    @IBOutlet weak var lblEstimateHour:UILabel?
    @IBOutlet weak var lblEstimateKilometer:UILabel?
    @IBOutlet weak var lblTotalOrder:UILabel?
    @IBOutlet weak var lblRoute:UILabel?
    @IBOutlet weak var lblTime:UILabel?
    @IBOutlet weak var lblStatus:UILabel?
    @IBOutlet weak var addNoteButton: UIButton!
    @IBOutlet weak var floatButtonViewContainer: UIView!
    
    var scrollMenu:ScrollMenuView?
    var mapVC:MapsViewController?
    var orderListVC:OrderListViewController?

    @IBOutlet weak var menuScrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionsViewContainer: UIView!
    
    @IBOutlet weak var actionViewContainerHeightConstraint: NSLayoutConstraint!
    //MARK: - VARIABLE
    private let identifierOrderListCell = "RouteDetailOrderListClvCell"
    private let identifieMapCell = "RouteDetailMapClvCell"
    private let identifierLocationsCell = "RouteDetailLocationListClvCell"
    private let identifierLoadPlanCell = "RouteDetailLoadPlanListClvCell"

    
    @IBOutlet weak var vanLoadButtonView: UIView!
    @IBOutlet weak var rejectButtonView: UIView!
    @IBOutlet weak var acceptButtonView: UIView!
    
    var isOrderFiltering:Bool = false
    
    var route:Route?
    var dateStringFilter:String = Date().toString()
    var oldRouteStatus = Status()
    var nextRouteStatus = Status()

    var displayMode:RouteDetailDisplayMode = ReachabilityManager.isNetworkAvailable ? .DisplayModeMap : .DisplayModeStops{
        didSet{
            updateUIWithMode(displayMode)
        }
    }
    
    var selectedTabBarItem:TabBarItem = .Order{
        didSet{
           updateNavigationBar()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        clvContent?.isHidden = true
        initUI()
//        initFloatButton()
//        handleShowingActionsContainer()
        updateActionsUI()
        setupCollectionView()
        setupScrollMenuView()
    }
    
    func layoutAddNoteButton() {
        addNoteButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        addNoteButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        addNoteButton.layer.shadowOpacity = 1.0
        addNoteButton.layer.shadowRadius = 10
        addNoteButton.layer.masksToBounds = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isOrderFiltering {
            getRouteDetail("\(route?.id ?? -1)")
        }
        isOrderFiltering = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    
    
    override func updateNavigationBar()  {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Back_Menu,"")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func filterOrdersAbleToLoad(orders:[Order]) -> [Order] {
        let filteredArray = orders.filter({$0.isDeliveryType})
        return filteredArray.filter({$0.statusOrder == StatusOrder.newStatus || $0.statusOrder == StatusOrder.WarehouseClarification})
    }
    
    func redirectToLoadingPackageVC() {
        guard let _route = route, let orders = route?.orderList else { return }
        let vc:LoadUnloadOrderVC = LoadUnloadOrderVC.loadSB(SB: .LoadUnloadOrder)
        vc.route = _route
        vc.orders = filterOrdersAbleToLoad(orders: orders)
        vc.callback = {[weak self] (hasUpdate,order) in
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    private func updateUIWithMode(_ displayMode:RouteDetailDisplayMode) {
        updateNavigationBar()
        if displayMode == .DisplayModeMap {
            //
        }else {
            //
        }
    }
    
    private func initUI()  {
        var startDate = "NA".localized
        var endDate = "NA".localized
        if let start = route?.start_time.date {
            startDate = HourFormater.string(from:start)
        }
        if let end = route?.end_time.date {
            endDate = HourFormater.string(from:end)
        }
        lblRoute?.text = "Route".localized + " #\(route?.companySeqID ?? "")"
        lblTime?.text = "\(startDate) - \(endDate)"
        lblStatus?.text = route?.status?.name?.localized
        lblStatus?.textColor = route?.colorStatus
        lblEstimateHour?.text = CommonUtils.formatEstTime(seconds: Int64(route?.totalTimeEst ?? 0))
        lblEstimateKilometer?.text = CommonUtils.formatEstKm(met: route?.totalDistance.doubleValue ?? 0)
        let totalOrders = route?.totalOrders ?? 0
        lblTotalOrder?.text = (totalOrders > 1) ? ("\(totalOrders) " + "orders".localized.uppercased()) : ("\(totalOrders) " + "order".localized.uppercased())
        
        lblStatus?.textColor = route?.colorStatus
        
//        layoutAddNoteButton()
        clvContent?.reloadData()
    }
    
    private func setupCollectionView() {
        clvContent?.delegate = self
        clvContent?.dataSource = self
    }

    @objc func setupScrollMenuView() {
        let mapMode = MenuItem("Map".localized.uppercased())
        let orderMode = MenuItem("Orders".localized.uppercased())
        let locationMode = MenuItem("locations".localized.uppercased())
        let loadPlanMode = MenuItem("load-plan".localized.uppercased())

        menuScrollView?.roundedCorners([.layerMaxXMinYCorner,
                                        .layerMinXMinYCorner,
                                        .layerMaxXMaxYCorner,
                                        .layerMinXMaxYCorner],10)
        menuScrollView?.backgroundCell = AppColor.white
        
        menuScrollView?.selectedBackground = AppColor.mainColor
        menuScrollView?.cornerRadiusCell = 10
        menuScrollView?.delegate = self
        menuScrollView?.isHidden = false
        let dataSource = [mapMode,orderMode,locationMode,loadPlanMode]
        menuScrollView?.dataSource = dataSource
        menuScrollView?.reloadData()
    }
    
//    func hideMenuScrollView() {
//        menuScrollView?.isHidden = true
//        menuScrollViewHeightConstraint.constant = 0.0
//        let displayOrders = 1
//        displayMode = RouteDetailDisplayMode(rawValue: displayOrders) ?? .DisplayModeMap
//        scrollToPageSelected(displayOrders)
//    }
    
    func updateRouteDetail(route:Route)  {
        self.route = route
        clvContent?.reloadData()
    }
    
    @IBAction func onNoteManagementTouchUp(_ sender: UIButton) {
        guard let _route = route else { return }
        let vc:NoteManagementViewController = .loadSB(SB: .Common)
        vc.route = _route
        vc.notes = _route.notes
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onAssignDriverTouchUp(_ sender: UIButton) {
        guard let _route = self.route else {
            showAlertView("something-went-wrong".localized)
            return }
        let vc:AssignDriverViewController = LoadUnloadOrderVC.loadSB(SB: .LoadUnloadOrder)
        vc.route = _route
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onAssignTruckTouchUp(_ sender: UIButton) {
        guard let _route = self.route else {
            showAlertView("something-went-wrong".localized)
            return }
        let vc:AssignTruckViewController = LoadUnloadOrderVC.loadSB(SB: .LoadUnloadOrder)
        vc.route = _route
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onVanLoadTouchUp(_ sender: UIButton) {
        self.redirectToLoadingPackageVC()
    }
    
    @IBAction func onRejectTouchUp(_ sender: UIButton) {
        self.showAlertView("are-you-sure-you-want-to-reject-this-route".localized, positiveTitle: "ok".localized, positiveAction: { (action) in
            self.nextRouteStatus = Route.RouteStatus.Rejected.convertToStatus()
            self.route?.status = self.nextRouteStatus
            self.updateRouteStatus(route: self.route)
        })
    }
    
    @IBAction func onAcceptTouchUp(_ sender: UIButton) {
        self.showAlertView("are-you-sure-you-want-to-accept-this-route".localized, positiveTitle: "ok".localized, positiveAction: { (action) in
            self.nextRouteStatus = Route.RouteStatus.Accepted.convertToStatus()
            self.route?.status = self.nextRouteStatus
            self.updateRouteStatus(route: self.route)
        })
    }
    
}

//MARK: - UICollectionViewDataSource
extension RouteDetailVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RouteDetailDisplayMode.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let displayMode = RouteDetailDisplayMode(rawValue: indexPath.row) else {
            return UICollectionViewCell()
        }
        
        switch displayMode {
        case .DisplayModeMap:
            return cellMap(collectionView,indexPath)
            
        case .DisplayModeStops:
            return cellOrderList(collectionView,indexPath)
            
        case .DisplayModeLocations:
            return cellLocationsList(collectionView, indexPath)
        case .DisplayLoadPlan:
            return cellLoadPlan(collectionView, indexPath)
        }
    }
    
    func cellMap(_ collectionView:UICollectionView,_ indexPath:IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifieMapCell,
                                                      for: indexPath) as! RouteDetailMapClvCell
        cell.route = route
        return cell
    }
    
    func cellOrderList(_ collectionView:UICollectionView,_ indexPath:IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifierOrderListCell,
                                                      for: indexPath) as! RouteDetailOrderListClvCell
        cell.rootVC = self
        cell.route = route
        cell.delegate = self
        return cell
    }
    
    func cellLocationsList(_ collectionView:UICollectionView,_ indexPath:IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifierLocationsCell,
                                                      for: indexPath) as! RouteDetailLocationListClvCell
        cell.rootVC = self
        cell.route = route
        return cell
    }
    
    func cellLoadPlan(_ collectionView:UICollectionView,_ indexPath:IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifierLoadPlanCell,
                                                      for: indexPath) as! RouteDetailLoadPlanListClvCell
        cell.rootVC = self
        cell.route = route
        return cell
    }
}

extension RouteDetailVC:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


//MARK: - UIScrollViewDelegate
extension RouteDetailVC:UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = clvContent?.frame.size.width ?? 0
        let offset =  scrollView.contentOffset
        let index = Int(offset.x / width)
        menuScrollView?.indexSelect = index
    }
}


//MARK: - BaseScrollMenuViewDelegate
extension RouteDetailVC:BaseScrollMenuViewDelegate{
    func baseScrollMenuViewDidSelectAtIndexPath(_ view: BaseScrollMenuView, _ indexPath: IndexPath) {
        self.view.endEditing(true)
        displayMode = RouteDetailDisplayMode(rawValue: indexPath.row) ?? .DisplayModeMap
        scrollToPageSelected(indexPath.row)
    }
    
    func scrollToPageSelected(_ index:Int) {
        let width = clvContent?.frame.size.width ?? 0
        let pointX = CGFloat(index) * width
        
        clvContent?.contentOffset =  CGPoint(x: pointX, y: (clvContent?.contentOffset.y)!);
    }
}


//MARK: - DMSNavigationServiceDelegate
extension RouteDetailVC:DMSNavigationServiceDelegate{
    func didSelectedMenuAction() {
        showSideMenu()
    }
    
    func didSelectedBackAction() {
        popViewController()
    }
}

//MARK: - RouteDetailOrderListClvCellDelegate
extension RouteDetailVC:RouteDetailOrderListClvCellDelegate{
    func didBeginEditSearchText() {
        self.clvContent?.isScrollEnabled = false
    }
    
    
    func didEndEditSearchText() {
        self.clvContent?.isScrollEnabled = true
    }
    
}

//MARK: - API
extension RouteDetailVC{
    
    func updateActionsUI() {
        guard let _route = route else { return }
//            assignDriverButtonView.isHidden = true
        assignTruckButtonView.isHidden = true
        vanLoadButtonView.isHidden = true
        rejectButtonView.backgroundColor = AppColor.redColor
        acceptButtonView.backgroundColor = AppColor.greenColor
        
        let isRequire = route?.status?.code == Route.RouteStatus.New.rawValue
        actionsViewContainer.isHidden = !isRequire
        actionViewContainerHeightConstraint.constant = isRequire ? 50.0 : 0.0
    }
    
    @objc func fetchData()  {
        if let route = self.route {
            getRouteDetail("\(route.id)", showLoading: false)
        }
    }
    
    func getRouteDetail(_ routeID:String, showLoading:Bool = true) {
        if ReachabilityManager.isNetworkAvailable {
            if showLoading {
                self.showLoadingIndicator()
            }
            SERVICES().API.getRouteDetail(route: routeID) {[weak self] (result) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.dismissLoadingIndicator()
                switch result{
                case .object(let obj):
                    strongSelf.route = obj.data
                    strongSelf.clvContent?.isHidden = false
                    strongSelf.clvContent?.reloadData()
                    strongSelf.initUI()
                    strongSelf.updateActionsUI()
                    
                     guard let data = obj.data else {return}
                     CoreDataManager.updateRoute(data) // Update route to DB local
                case .error(let error):
                    strongSelf.showAlertView(error.getMessage())
                    
                }
            }
        } else {
            self.route = CoreDataManager.getRoute(routeID)
            self.clvContent?.endRefreshControl()
            self.clvContent?.isHidden = false
            self.clvContent?.reloadData()
            self.initUI()
            self.updateActionsUI()
        }
    }
    
    func updateRouteStatus(route:Route?){
        guard let _route = route else { return }
        if self.hasNetworkConnection {
            self.showLoadingIndicator()
        }
        SERVICES().API.updateRouteStatus(route:_route) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.fetchData()
                break
            case .error(let error):
                self?.route?.status = self?.oldRouteStatus
                self?.showAlertView(error.getMessage())
            }
        }
    }
}
