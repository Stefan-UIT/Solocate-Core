//
//  AssignDriverViewController.swift
//  DMSDriver
//
//  Created by Trung Vo on 7/29/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class AssignDriverViewController: BaseViewController {
    let driverCellIdentifier = "AssignDriverTableViewCell"
    @IBOutlet weak var tableView: UITableView!
    var route:Route!
    var drivers:[Driver] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData()
        // Do any additional setup after loading the view.
    }
    
    override func updateNavigationBar() {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.BackOnly, "")
    }
    
    func fetchData() {
        self.showLoadingIndicator()
        SERVICES().API.getDriverList(byRoute: route) { [weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result {
            case .object(let obj):
                print(obj)
                self?.drivers = obj.data ?? []
                self?.tableView.reloadData()
            case .error(let error):
                self?.showAlertView(error.description)
            }
        }
    }
    
    func showAssignDriverPopup(driver:Driver) {
        let name = driver.userName ?? "-"
        let title = "Assign Driver"
        let message = "Are you sure you want to assign \(name) to this route?"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "confirm".localized, style: .default, handler: { [weak alert] (_) in
            self.submitAssigningDriver(driver)
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: {
            action in
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func submitAssigningDriver(_ driver:Driver) {
        self.showLoadingIndicator()
        SERVICES().API.assignDriver(driver.id, toRoute: route.id) { [weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result {
            case .object(let obj):
                let message = obj.message ?? ""
                self?.showAlertView(message, completionHandler: { (action) in
                    self?.navigationController?.popViewController(animated: true)
                })
            case .error(let error):
                self?.showAlertView(error.description)
            }
        }
    }

}

extension AssignDriverViewController:DMSNavigationServiceDelegate {
    func didSelectedBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: UITableView
extension AssignDriverViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drivers.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: driverCellIdentifier) as? AssignDriverTableViewCell {
            let driver = drivers[indexPath.row]
            cell.configureCell(driver: driver)
            return cell
        }
        return UITableViewCell()
    }
}


//MARK: - UITableViewDelegate
extension AssignDriverViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let driver = drivers[indexPath.row]
        showAssignDriverPopup(driver: driver)
//        let vc:RouteDetailVC = RouteDetailVC.loadSB(SB: .Route)
//        vc.route = routes[indexPath.row]
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}
