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
    
    
    var currentDateString: String = "2019-01-21"
    var routes = [Route]()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //getRoutes(currentDateString)
    }
    
    override func updateNavigationBar() {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Menu_Search, "")
    }
    
    func setupTableView()  {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: ClassName(RouteTableViewCell()),
                                 bundle: nil),
                           forCellReuseIdentifier: identifierRowCell)
       
    }
 }
 
 //MARK: - DMSNavigationServiceDelegate
 extension RouteListVC:DMSNavigationServiceDelegate {
    func didSelectedBackOrMenu() {
        showSideMenu()
    }
    
    func didSelectedLeftButton(_ sender: UIBarButtonItem) {
        FilterDataListVC.show(atViewController: self) { (success, data) in
            //
        }
    }
 }
 
 
 // MARK: UITableView
 extension RouteListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 //routes.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifierRowCell) as? RouteTableViewCell {
            //let route = routes[indexPath.row]
            //cell.loadData(route)
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
        print("Y: \(contentOffsetY)")
        lblNameDriver?.alpha = 1 / contentOffsetY
        lblDate?.alpha = 1 / contentOffsetY
        if contentOffsetY <= viewHiDriver?.frame.size.height ?? 0  {
            conTopViewHiDriver?.constant = -contentOffsetY
        }
    }
    
    func updateNavigationBar(isShowTitle:Bool)  {
        if isShowTitle == false{
            App().navigationService.updateNavigationBar(.Menu_Search, "")
        }
        else {
            App().navigationService.updateNavigationBar(.Menu_Search, "List Routes".localized.uppercased())
            
        }
    }
 }
 
 //MARK: - API
 fileprivate extension RouteListVC {
    func getRoutes(_ date: String? = Date().toString()) {
        showLoadingIndicator()
        API().getRoutes(byDate: date) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(let obj):
                if let data = obj.data {
                    self?.routes = data.data ?? []
                   // DMSCurrentRoutes.routes = data
                    self?.tableView.reloadData()
                    
                } else {
                    // TODO: Do something.
                }
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
 }




 

