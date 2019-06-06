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

enum TabBarItem:Int {
    case Order = 0
    case Packages;
    case Map;
    case Messages;
    
    func title() -> String {
        switch self {
        case .Order:
            return "Orders List".localized
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
    
    static var count: Int {
        return RouteDetailDisplayMode.DisplayModeLocations.hashValue + 1
    }
}

class RouteDetailVC: BaseViewController {
    
    //MARK: - IBOUTLET
    @IBOutlet weak var menuScrollView:BaseScrollMenuView?
    @IBOutlet weak var clvContent:UICollectionView?
    @IBOutlet weak var lblEstimateHour:UILabel?
    @IBOutlet weak var lblEstimateKilometer:UILabel?
    @IBOutlet weak var lblTotalOrder:UILabel?
    @IBOutlet weak var lblRoute:UILabel?
    @IBOutlet weak var lblTime:UILabel?
    @IBOutlet weak var lblStatus:UILabel?

    /*
    @IBOutlet weak var vContainerMap:UIView?
    @IBOutlet weak var vContainerOrders:UIView?
     */

    var scrollMenu:ScrollMenuView?
    var mapVC:MapsViewController?
    var orderListVC:OrderListViewController?


    //MARK: - VARIABLE
    private let identifierOrderListCell = "RouteDetailOrderListClvCell"
    private let identifieMapCell = "RouteDetailMapClvCell"
    private let identifieLocationsCell = "RouteDetailLocationListClvCell"

    
    var route:Route?
    var dateStringFilter:String = Date().toString()


    var displayMode:RouteDetailDisplayMode = .DisplayModeMap{
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
        initUI()
        setupCollectionView()
        setupScrollMenuView()
        
        guard let routeId = route?.id else {
            return
        }
        getRouteDetail("\(routeId)")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBar()
    }

    
    
    override func updateNavigationBar()  {
        super.updateNavigationBar()
        App().navigationService.delegate = self;
        if displayMode == .DisplayModeMap {
            App().navigationService.updateNavigationBar(.Menu,"")
        }else {
            App().navigationService.updateNavigationBar(.Menu_Search,"")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let startDate = HourFormater.string(from: route?.start_time.date ?? Date())
        let endDate = HourFormater.string(from: route?.end_time.date ?? Date())
        lblRoute?.text = "Route #\(route?.id ?? 0)".localized
        lblTime?.text = "\(startDate) - \(endDate)"
        lblStatus?.text = route?.status?.name
        lblStatus?.textColor = route?.colorStatus
        lblEstimateHour?.text = CommonUtils.formatEstTime(seconds: Int64(route?.totalTimeEst ?? 0))
        lblEstimateKilometer?.text = CommonUtils.formatEstKm(met: route?.totalDistance.doubleValue ?? 0)
        lblTotalOrder?.text = "\(route?.totalOrders ?? 0) Orders".localized.uppercased()
        
        lblStatus?.textColor = route?.colorStatus
    }
    
    private func setupCollectionView() {
        clvContent?.delegate = self
        clvContent?.dataSource = self
    }

    @objc func setupScrollMenuView() {
        let mapMode = MenuItem("Map".localized.uppercased())
        let orderMode = MenuItem("Orders".localized.uppercased())
        let locationMode = MenuItem("Locations".localized.uppercased())

        menuScrollView?.roundedCorners([.layerMaxXMinYCorner,
                                        .layerMinXMinYCorner,
                                        .layerMaxXMaxYCorner,
                                        .layerMinXMaxYCorner],10)
        menuScrollView?.backgroundCell = AppColor.white
        menuScrollView?.selectedBackground = AppColor.mainColor
        menuScrollView?.cornerRadiusCell = 10
        menuScrollView?.delegate = self
        menuScrollView?.isHidden = false
        menuScrollView?.dataSource = [mapMode,orderMode,locationMode]
        menuScrollView?.reloadData()
    }
    
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
        return cell
    }
    
    func cellLocationsList(_ collectionView:UICollectionView,_ indexPath:IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifieLocationsCell,
                                                      for: indexPath) as! RouteDetailLocationListClvCell
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
    func didSelectedBackOrMenu() {
        showSideMenu()
    }
    
    func didSelectedLeftButton(_ sender: UIBarButtonItem) {
 
    }
}

//MARK: - API
extension RouteDetailVC{
    
    @objc func fetchData()  {
        if let route = self.route {
            getRouteDetail("\(route.id)", showLoading: false)
        }
    }
    
    func getRouteDetail(_ routeID:String, showLoading:Bool = true) {
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
                self?.route = obj.data
                self?.clvContent?.reloadData()
                /*
                 guard let data = obj.data else {return}
                 CoreDataManager.updateRoute(data) // Update route to DB local
                 */
            case .error(let error):
                strongSelf.showAlertView(error.getMessage())
                
            }
        }
    }
}
