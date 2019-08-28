 //
//  RouteListVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import SideMenu
import Crashlytics
 
 class RouteListVC: BaseViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblNoResult:UILabel?
    @IBOutlet weak var viewHiDriver:UIView?
    @IBOutlet weak var lblNameDriver:UILabel?
    @IBOutlet weak var lblDate:UILabel?
    @IBOutlet weak var conTopViewHiDriver:NSLayoutConstraint?

    
    private let identifierRowCell = "RouteTableViewCell"
    var timeData:TimeDataItem?
    var routes = [Route]()
    var filterModel = FilterDataModel()
    var isFromDashboard = false
    var isFromFilter = false

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initVar()
        initUI()
        //fakaData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromDashboard == false && isFromFilter == false{
            fetchData(isShowLoading: true)
        } else if isFromFilter {
            isFromFilter = false
        }
    }
    
    override func updateNavigationBar() {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Filter_Menu, "")
    }
    
    private func setupTableView()  {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: ClassName(RouteTableViewCell()),
                                 bundle: nil),
                           forCellReuseIdentifier: identifierRowCell)
        if isFromDashboard == false {
            tableView.addRefreshControl(self, action: #selector(fetchData(isShowLoading:)))
        }       
    }
    
    private func initVar()  {
        if timeData == nil {
            timeData = TimeData.getTimeDataItemType(type: .TimeItemTypeToday)
            filterModel.timeData = timeData
        }
    }
    
    private func initUI()  {
        setupTableView()
        let userName = Caches().user?.userInfo?.userName ?? ""
//        let date = #"Here is your plan for today - \#(ShortDateFormater.string(from: filterModel.timeData?.startDate ?? Date()))"#.localized
        let date = "here-is-your-plan".localized
        lblNameDriver?.text = "hi".localized + " \(userName)"
        lblDate?.text = date
    }
    
    @objc func fetchData(isShowLoading:Bool = true)  {
        getRoutes(filterMode: filterModel, isShowLoading: isShowLoading)
    }
    
    func updateRouteList(routeNeedUpdate:Route) {
        for (index,route) in self.routes.enumerated() {
            if route.id == routeNeedUpdate.id {
                self.routes[index] = routeNeedUpdate
                break
            }
        }
        tableView.reloadData()
    }
 }
 
 //MARK: - DMSNavigationServiceDelegate
 extension RouteListVC:DMSNavigationServiceDelegate {
//    func didSelectedBackOrMenu() {
//        showSideMenu()
//    }
    
    func didSelectedMenuAction() {
        showSideMenu()
    }
    
    func didSelectedBackAction() {
        popViewController()
    }
    
    func didSelectedLeftButton(_ sender: UIBarButtonItem) {
        FilterDataListVC.show(atViewController: self,currentFilter: filterModel) {[weak self] (success, data) in
            guard let strongSelf = self,success == true else{
                return
            }
            strongSelf.filterModel = data
            strongSelf.fetchData(isShowLoading: true)
        }
        self.isFromFilter = true
    }
 }
 
 
 // MARK: UITableView
 extension RouteListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifierRowCell) as? RouteTableViewCell {
            let route = routes[indexPath.row]
            cell.loadData(route)
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
 }
 
 
 //MARK: - UITableViewDelegate
 extension RouteListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.clear
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let vc:RouteDetailVC = RouteDetailVC.loadSB(SB: .Route)
        vc.route = routes[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
 }
 
 
 //MARK: - UIScrollViewDelegate
 extension RouteListVC:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let heightViewHiDriver = viewHiDriver?.frame.size.height ?? 0
        updateViewHiDriverFollowScrollView(scrollView: scrollView)
        updateNavigationBar(isShowTitle: contentOffsetY > heightViewHiDriver)
    }
    
    func updateViewHiDriverFollowScrollView(scrollView:UIScrollView)  {
        let contentOffsetY = scrollView.contentOffset.y
        let heightViewHiDriver = viewHiDriver?.frame.size.height ?? 60
        var max:CGFloat = 0
        if contentOffsetY > 0 {
            max = MAX(-contentOffsetY, -heightViewHiDriver)
            lblNameDriver?.alpha = 1 / (contentOffsetY / 2)
            lblDate?.alpha = 1 / (contentOffsetY / 2)
        }else{
            max = 0
            lblNameDriver?.alpha = 1
            lblDate?.alpha = 1
        }
        conTopViewHiDriver?.constant = max
    }
    
    func updateNavigationBar(isShowTitle:Bool)  {
        if isShowTitle == false{
            App().navigationService.updateNavigationBar(.Filter_Menu, "")
        }
        else {
            App().navigationService.updateNavigationBar(.Filter_Menu, "list-routes".localized.uppercased())
            
        }
    }
 }
 
 //MARK: - API
 fileprivate extension RouteListVC {
    func getRoutes(filterMode:FilterDataModel, isShowLoading:Bool = true) {
        if isShowLoading {
            showLoadingIndicator()
        }
        
        SERVICES().API.getRoutes(filterMode: filterMode) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            self?.tableView.endRefreshControl()
            guard let strongSelf = self else {
                return
            }
            switch result{
            case .object(let obj):
                if let data = obj.data {
                    strongSelf.routes = data
                    // DMSCurrentRoutes.routes = data
                    strongSelf.lblNoResult?.isHidden = (strongSelf.routes.count > 0)
                    strongSelf.tableView.reloadData()
                    
                } else {
                    // TODO: Do something.
                }
                
            case .error(let error):
                strongSelf.showAlertView(error.getMessage())
            }
        }
    }
    
 }




 

