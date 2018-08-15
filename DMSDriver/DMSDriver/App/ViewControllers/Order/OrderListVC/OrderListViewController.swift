//
//  OrderListViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import SVProgressHUD

enum TapFilterOrderList:Int {
    case All = 0
    case Assigned
    case Mine
}

class OrderListViewController: BaseViewController {
  
    @IBOutlet weak var clvContent: UICollectionView?
    @IBOutlet weak var segmentControl: UISegmentedControl?
    @IBOutlet weak var conHeightViewSegment: NSLayoutConstraint?
    
    fileprivate var tapDisplay: TapFilterOrderList = .All {
        didSet{
            clvContent?.reloadData()
        }
    }

    
    var route: Route?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        if let route = self.route {
            getRouteDetail("\(route.id)")
        }
    }

  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    func setupCollectionView() {
        clvContent?.delegate = self
        clvContent?.dataSource = self
    }
    
    func updateUI()  {
        setupCollectionView()
    }
    
    
    //MARK: -Action
    @IBAction func onbtnClickSegment(segment:UISegmentedControl){
        if let tapSelect = TapFilterOrderList(rawValue: segment.selectedSegmentIndex){
            tapDisplay = tapSelect
        }
        scrollToPageSelected(segment.selectedSegmentIndex)
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
        cell.tapDisplay = tapDisplay
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
        segmentControl?.selectedSegmentIndex = Int(index)
        if let tapSelect = TapFilterOrderList(rawValue: Int(index)){
            tapDisplay = tapSelect
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
        if !isFetch {
            self.showLoadingIndicator()
        }
        API().getRouteDetail(route: routeID) {[weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.dismissLoadingIndicator()

            switch result{
            case .object(let obj):
                strongSelf.route = obj
                strongSelf.clvContent?.reloadData()
            case .error(let error):
                strongSelf.showAlertView(error.getMessage())
                
            }
        }
    }
    
    func getOrderByCoordinator() {
        self.showLoadingIndicator()
        SERVICES().API.getOrderByCoordinator {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(let obj):
                break
            case .error(let error):
                self?.showAlertView(error.getMessage())
                break
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



