//
//  AssignOrderVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 8/15/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import SideMenu


class AssignOrderVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noOrdersLabel: UILabel?
    
    fileprivate let cellIdentifier = "OrderItemTableViewCell"
    fileprivate let cellHeight: CGFloat = 150.0
    
    fileprivate var orderList:[Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getListOrderAssign()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func updateNavigationBar() {
        self.navigationService.delegate = self
        self.navigationService.updateNavigationBar(.Menu, "Assign")
    }
    
    func updateUI() {
        setupTableView()
        noOrdersLabel?.isHidden = orderList.count > 0
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addRefreshControl(self, action: #selector(fetchData))
    }
}

// MARK: - Private methods

extension AssignOrderVC {
    func convertString(_ text: String, withFormat format: String = "yyyy-MM-dd") -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let date = dateFormater.date(from: text) ?? Date()
        dateFormater.dateFormat = format
        
        return dateFormater.string(from: date)
        
    }
}


//MARK: - UITableViewDelegate,UITableViewDataSource
extension AssignOrderVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderList.count
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderItemTableViewCell {
            
            let order = orderList[indexPath.row]
            cell.order = order
            cell.btnNumber?.setTitle("\(indexPath.row + 1)", for: .normal)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AssignOrderVC:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        if Constants.isLeftToRight {
            present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
        }else{
            present(SideMenuManager.default.menuRightNavigationController!, animated: true, completion: nil)
        }
    }
}


//MARK: - API
extension AssignOrderVC{
    
    @objc func fetchData()  {
        getListOrderAssign(isFetch: true)
    }
    
    func getListOrderAssign(isFetch:Bool = false) {
        if !isFetch {
            self.showLoadingIndicator()
        }
        API().getOrderByCoordinator{[weak self] (result) in
            switch result{
            case .object(let obj):
                guard let data = obj.data else{return}
                self?.orderList = data
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}

