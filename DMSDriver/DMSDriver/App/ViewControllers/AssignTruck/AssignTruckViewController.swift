//
//  AssignDriverViewController.swift
//  DMSDriver
//
//  Created by Trung Vo on 7/29/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class AssignTruckViewController: BaseViewController {
    let truckCellIdentifier = "AssignTruckTableViewCell"
    @IBOutlet weak var tableView: UITableView!
    var route:Route!
    var trucks:[Truck] = []
    
    @IBOutlet weak var companyLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        companyLabel.text = Slash(route.company?.name)
        self.fetchData()
        // Do any additional setup after loading the view.
    }
    
    override func updateNavigationBar() {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.BackOnly, "")
    }
    
    func fetchData() {
        guard let _route = self.route else { return }
        self.showLoadingIndicator()
        SERVICES().API.getTruckList(byRoute: _route) { [weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result {
            case .object(let obj):
                print(obj)
                self?.trucks = obj.data ?? []
                self?.tableView.reloadData()
            case .error(let error):
                self?.showAlertView(error.description)
            }
        }
    }
    
    func showAssignTruckPopup(truck:Truck) {
        let name = truck.plateNumber
        let title = "assign-truck".localized
        let message = String(format: "are-you-sure-you-want-to-assign-to-this-route".localized, "\(name)")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "confirm".localized, style: .default, handler: { [weak alert] (_) in
            self.submitAssigningTruck(truck)
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: {
            action in
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func submitAssigningTruck(_ truck:Truck) {
        self.showLoadingIndicator()
        SERVICES().API.assignTruck(truck.id, toRoute: route.id) { [weak self] (result) in
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

extension AssignTruckViewController:DMSNavigationServiceDelegate {
    func didSelectedBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: UITableView
extension AssignTruckViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trucks.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: truckCellIdentifier) as? AssignTruckTableViewCell {
            let truck = trucks[indexPath.row]
//            cell.configureCell(driver: driver)
            cell.configureCell(truck: truck)
            return cell
        }
        return UITableViewCell()
    }
}


//MARK: - UITableViewDelegate
extension AssignTruckViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let truck = trucks[indexPath.row]
        showAssignTruckPopup(truck: truck)
//        let vc:RouteDetailVC = RouteDetailVC.loadSB(SB: .Route)
//        vc.route = routes[indexPath.row]
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}
