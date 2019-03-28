//
//  OrderListViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import SVProgressHUD
import FDFullscreenPopGesture

enum TapFilterOrderList:Int {
    case All = 0
    case New
    case InProgess
    case Finished
    case Cancelled
    
    var title:String{
        
        switch self {
        case .All:
            return "All".localized
        case .New:
            return "New".localized
        case .InProgess:
            return "In Progress".localized
        case .Finished:
            return "Finished".localized
        case .Cancelled:
            return "Cancelled".localized
        }
    }
    

}

enum DisplayMode:Int {
    case Reduced = 0
    case Expanded
    
}

class OrderListViewController: BaseViewController {
  
    @IBOutlet weak var clvContent: UICollectionView?
    @IBOutlet weak var lblFilter: UILabel?
    @IBOutlet weak var btnSwitchMode: UIButton?

    
    var arrDropDownMenu:[String] = []
    var route: Route?
    var dateStringFilter = Date().toString()
    var isLoading = true
    
    fileprivate var tapFilterOrderList : TapFilterOrderList = .All {
        didSet{
            clvContent?.reloadData()
        }
    }
    
    var displayMode:DisplayMode = DisplayMode.Expanded{
        didSet{
            clvContent?.reloadData()
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        updateArrDropDownMenu()
        updateUI()
        self.fd_prefersNavigationBarHidden = true;
    }

  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hasNetworkConnection {
            if let route = self.route {
                //getRouteDetail("\(route.id)")
            }
        }else{
            //getDataFromLocalDB()
        }
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func reachabilityChangedNetwork(_ isAvailaibleNetwork: Bool) {
        super.reachabilityChangedNetwork(isAvailaibleNetwork)
        if hasNetworkConnection {
            if let route = self.route {
                // getRouteDetail("\(route.id)")
            }
        }else{
            //getDataFromLocalDB()
        }
    }
    
    func getDataFromLocalDB()  {
        if let route = self.route{
            self.showLoadingIndicator()
            CoreDataManager.queryRouteBy(route.id, {[weak self] (success, _route) in
                self?.dismissLoadingIndicator()
                if success{
                    self?.route = _route
                    self?.updateUI()
                    self?.clvContent?.reloadData()
                }
            })
        }
    }
    
    //MARK: - Intialize
    func updateLblFilter() {
        lblFilter?.text = arrDropDownMenu[tapFilterOrderList.rawValue]
    }
    
    func updateArrDropDownMenu()  {
        arrDropDownMenu = ["All".localized.appending(" (\(route?.orderList.count ?? 0))"),
                           "New".localized.appending(" (\(route?.orders(.newStatus).count ?? 0))"),
                           "In Progress".localized.appending(" (\(route?.orders(.inProcessStatus).count ?? 0))"),
                           "Finished".localized.appending(" (\(route?.orders(.deliveryStatus).count ?? 0))"),
                           "Cancelled".localized.appending(" (\(route?.orders(.cancelStatus).count ?? 0))")]
    }
    
    func setupCollectionView() {
        clvContent?.delegate = self
        clvContent?.dataSource = self
    }
    
    override func updateUI()  {
        super.updateUI()
        DispatchQueue.main.async {[weak self] in
            self?.setupCollectionView()
            self?.updateArrDropDownMenu()
            self?.updateLblFilter()
        }
    }
    
    //MARK: -Action
    @IBAction func onbtnClickSwitchMode(btn:UIButton){
        btn.isSelected = !btn.isSelected
        if displayMode == .Expanded {
            displayMode = .Reduced
        }else{
            displayMode = .Expanded
        }
    }
}

//MARK: - UICollectionViewDataSource
extension OrderListViewController: UICollectionViewDataSource {
  
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderListClvCell", for: indexPath) as! OrderListClvCell
        cell.rootVC = self
        cell.route = route
        if !isLoading {
            cell.filterOrderList = tapFilterOrderList
        }
        cell.displayMode = displayMode
        cell.dateStringFilter = dateStringFilter
        return cell
    }
}

extension OrderListViewController:UICollectionViewDelegateFlowLayout{
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

extension OrderListViewController:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / ScreenSize.SCREEN_WIDTH
        if let tapSelect = TapFilterOrderList(rawValue: Int(index)){
            tapFilterOrderList = tapSelect
        }
    }
}

//MARK: - API
extension OrderListViewController{
    
    @objc func fetchData()  {
        if let route = self.route {
            getRouteDetail("\(route.id)", isFetch: true)
        }
    }
    
    func getRouteDetail(_ routeID:String, isFetch:Bool = false) {
        let count = CoreDataManager.countRequestLocal()
        if count > 0 {
            return
        }
        
        if !isFetch {
            self.showLoadingIndicator()
        }
        isLoading = true
        SERVICES().API.getRouteDetail(route: routeID) {[weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.dismissLoadingIndicator()
            strongSelf.isLoading = false
            switch result{
            case .object(let obj):
                self?.route = obj.data
                self?.updateUI()
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

//MARK: -OtherFuntion
extension OrderListViewController{
    func scrollToPageSelected(_ index:Int) {
        let width = self.view.frame.size.width
        let pointX = CGFloat(index) * width
        
        clvContent?.contentOffset =  CGPoint(x: pointX, y: (clvContent?.contentOffset.y)!);
    }
}



