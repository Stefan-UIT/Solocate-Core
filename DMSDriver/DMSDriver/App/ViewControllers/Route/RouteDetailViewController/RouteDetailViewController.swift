//
//  RouteDetailViewController.swift
//  SRSDriver
//
//  Created by MrJ on 1/22/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit

class RouteDetailViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var letsStartButton: UIButton!
    @IBOutlet weak var highConstraintLetsStartButton: NSLayoutConstraint!
    
    // MARK: Variables
    private var leftBarButtonItem = UIBarButtonItem()
    //private var pointToDrawMap = [LocationToDrawMapModel]()
    
    // MARK: Variables
    var isStarted = true
    var typeSelected = RouteDetailHeaderTableView.TypeSelected.MAP
    let headerView = RouteDetailHeaderTableView()
    
    var routeID: Int?
    var route: Route?
    private var pointToDrawMap = [LocationToDrawMapModel]()

    // MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()

        //configRightBarButtonItem(.MainMenu)
        
        tableView.register(UINib(nibName: "MapRouteDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "MapRouteDetailTableViewCell")
        tableView.register(UINib(nibName: "RouteDetailOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "RouteDetailOrderTableViewCell")

        tableView.estimatedRowHeight = 170.0
        tableView.rowHeight = UITableViewAutomaticDimension

        headerView.delegate = self
        letsStartButton.alpha = 0.0
        highConstraintLetsStartButton.constant = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData { [weak self] () in
            self?.updateView()
        }
    }
    // MARK: Function
    private func loadData(_ completionHanlder:(()->())? = nil) {
        /*
        guard let routeID = routeID else {
            return
        }
        showLoadingIndicator()
        API().getRouteDetail(routeID: "\(routeID)") { [weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result {
            case .object(let response):
                if let route = response.data {
                    self?.route = route
                    completionHanlder!()
                }
                break
            case .error(let error):
                let message = error.getMessage()
                self?.showAlert(message)
                break
            }
        }
         */
    }
    
    private func updateView() {
        /*
        guard let route = route else {
            return
        }
        if route.routeStsCd?.compare(OrderStatus.open.rawValue) == ComparisonResult.orderedSame && isStarted {
            letsStartButton.alpha = 1.0
            highConstraintLetsStartButton.constant = 66.0
        } else {
            highConstraintLetsStartButton.constant = 0.0
            letsStartButton.isUserInteractionEnabled = false
        }
        self.route = route
        
        pointToDrawMap.removeAll()
        if let locations = route.locations {
            for location in locations {
                let seq = location.seq
                let latitude = Double(location.lattd ?? "0")
                let longitude = Double(location.lngtd ?? "0")
                pointToDrawMap.append(LocationToDrawMapModel(seq, latitude, longitude))
            }
        }
        tableView.reloadData()
         */
    }
    
    private func handleStartRoute() {
        /*
        guard let routeId = route?.id,
        let estStartDate = route?.date else {
            return
        }
        self.showLoadingIndicator()
        API().startRoute("\(routeId)",estStartDate) { [weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(let data):
                if let status = data.data?.status,status {
                    self?.handleStartRouteSuccessful()
                } else if let msg = data.data?.message,
                    let date = data.data?.date {
                    let _date = Date().UTCToLocal(date, "yyyy-MM-dd HH:mm", "yyyy-MM-dd")
                    let _msg = msg.replacingOccurrences(of: "date", with: _date)
                    self?.handleStartRouteFailure(_msg)
                } else {
                    self?.showAlert("ERROR UNKNOWN")
                }
                return
            case .error(let error):
                let msg = error.getMessage()
                self?.showAlert(msg)
            }
        }
         */
    }
    
    private func handleStartRouteFailure(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Done", style: .cancel) { (action) in
            self.tabBarController?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func handleStartRouteSuccessful() {
        /*
        loadData { [weak self] () in
            let viewController = StartOrderViewController()
            viewController.location = self?.route?.locations?.first
            viewController.pointToDraw = self?.pointToDrawMap
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
         */
    }
    
    
    // MARK: Action
    @IBAction func startButtonAction(_ sender: UIButton) {
        handleStartRoute()
    }
}

// MARK: UITableView
extension RouteDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch typeSelected {
        case .MAP:
            return 1
        case .STOPS_FULL, .STOPS_SHORT:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch typeSelected {
        case .MAP:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MapRouteDetailTableViewCell") as? MapRouteDetailTableViewCell {
                cell.selectionStyle = .none
                cell.loadData(nil)

                return cell
            }
        case .STOPS_FULL:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "RouteDetailOrderTableViewCell") as? RouteDetailOrderTableViewCell {
                return cell
            }
        case .STOPS_SHORT:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "RouteDetailOrderTableViewCell") as? RouteDetailOrderTableViewCell {
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension RouteDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 123.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let route = route {
            headerView.loadData(route)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

    }
}

// MARK: RouteDetailHeaderTableViewDelegate
extension RouteDetailViewController: RouteDetailHeaderTableViewDelegate {
    func routeDetailHeaderTableView(_ view: RouteDetailHeaderTableView, _ valueSelected: RouteDetailHeaderTableView.TypeSelected) {
        handleChangeTypeDisplay(valueSelected)
    }
    
    func handleChangeTypeDisplay(_ valueSelected: RouteDetailHeaderTableView.TypeSelected) {
        typeSelected = valueSelected
        tableView.reloadData()
    }
}


