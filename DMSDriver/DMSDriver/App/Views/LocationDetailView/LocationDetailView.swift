//
//  LocationDetailView.swift
//  DMSDriver
//
//  Created by Seldat on 5/10/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class LocationDetailView: UIViewController {
    enum LocationViewSection:Int {
        case Location = 0
        case Deliver
        case Pickup
    }
    
    @IBOutlet weak var tbvContent:UITableView?
    
    private let headerIdentifierCell = "LocationDetailHeaderCell"
    private let packageIdentifierCell = "LocationDetailPackageCell"
    private let addressIdentifierCell = "LocationDetailAddressCell"

    private let titleHeader = ["location".localized.uppercased(),
                               "Deliver".localized.uppercased(),
                               "Pickup".localized.uppercased()]
    
    private var delivers:[Order.Detail] = []
    private var pickups:[Order.Detail] = []

    var location:GroupLocatonModel? {
        didSet {
            delivers = location?.getDeliverPackages() ?? []
            pickups = location?.getPickupPackages() ?? []
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setupTableView() {
        tbvContent?.dataSource = self
        tbvContent?.delegate = self
    }
    
    //MARK: - ACTION
    @IBAction func onbtnClickClose(btn:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension LocationDetailView:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleHeader.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let locationSection = LocationViewSection(rawValue: section) else {
            return 0
        }
        switch locationSection {
        case .Location:
            return 1
        case .Deliver:
            return (delivers.count > 0) ? 1 : 0
        case .Pickup:
            return (pickups.count > 0) ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let locationSection = LocationViewSection(rawValue: section) else {
            return 0
        }
        switch locationSection {
        case .Location:
            return 35
        case .Deliver:
            return delivers.count > 0 ? 35 : 0
        case .Pickup:
            return pickups.count > 0 ? 35 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == LocationViewSection.Location.rawValue {
            return 140
        }
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let locationSection = LocationViewSection(rawValue: section) else {
            return 0
        }
        switch locationSection {
        case .Location:
            return (delivers.count > 0 || pickups.count > 0) ? 10 : 0
        case .Deliver:
            return (pickups.count > 0 && delivers.count > 0) ? 10 : 0
        case .Pickup:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: headerIdentifierCell) as! LocationDetailViewCell
        header.lblTitle?.text = titleHeader[section]
        
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = AppColor.grayColor
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        guard let locationSection = LocationViewSection(rawValue: section) else {
            return UITableViewCell()
        }
        switch locationSection {
        case .Location:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: addressIdentifierCell, for: indexPath) as! LocationDetailViewCell
            var startDate = ""
            if let date = location?.address?.start_time?.date {
                startDate =  DateFormatter.displayDateTimeVN.string(from:date)
            }
            
            var endDate = ""
            if let date = location?.address?.end_time?.date {
                endDate =  DateFormatter.displayDateTimeVN.string(from:date)
            }
            
            cell.selectionStyle = .none
            cell.lblTitle?.text = location?.address?.address
            cell.lblSubTitle?.text = "\(location?.address?.ctt_name ?? "") | \(location?.address?.ctt_phone ?? "")"
            cell.lblExpectedTime?.text = "\(startDate) - \(endDate)"
            cell.lblLocationName?.text = "location-name".localized + ": \(location?.address?.loc_name ?? "")"

            return cell
            
        case .Deliver:
            let cell = tableView.dequeueReusableCell(withIdentifier: packageIdentifierCell, for: indexPath) as! LocationDetailViewCell
            
            let subTitle = locationDetailSubTitle(details: delivers)
            let subTitle2 = locationDetailSubTitle2(details: delivers)
//            cell.lblSubTitle?.text = (deliver.package?.name != nil) ? deliver.package?.name : "package".localized + ": \(row + 1)"
            cell.lblSubTitle?.text = subTitle
            cell.lblSubTitle2?.text = subTitle2

            return cell
        case .Pickup:
            let cell = tableView.dequeueReusableCell(withIdentifier: packageIdentifierCell, for: indexPath) as! LocationDetailViewCell
            
            
            let subTitle = locationDetailSubTitle(details: pickups)
            let subTitle2 = locationDetailSubTitle2(details: pickups)
            
            cell.lblSubTitle?.text = subTitle
            cell.lblSubTitle2?.text = subTitle2

            
            return cell
        }
    }
    
    func locationDetailSubTitle2(details: [Order.Detail]) -> String {
        var result = ""
        var skusName = ""
        for detail in details {
            skusName = skusName == "" ? (detail.name ?? "") : skusName + ", " + (detail.name ?? "")
        }
        result += "SKUs".localized + ": " + "\(skusName)"
        return result
    }
    
    func locationDetailSubTitle(details:[Order.Detail]) -> String {
        var cartonsQty = 0
        
        var result = ""
        for item in details {
            cartonsQty += item.pivot?.qty ?? 0
            if !result.isEmpty {
                result += ""
            } else {
                result += "Total quantity".localized + ": " + "\(cartonsQty)"
            }
        }
        return result
    }
}

// MARK: - UITableViewDelegate
extension LocationDetailView:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
}


// MARK: - Static Method
extension LocationDetailView {
    public static func showLocationViewDetail(at viewController:UIViewController? = nil,location:GroupLocatonModel) {
        let vc:LocationDetailView = LocationDetailView.loadSB(SB: .LocationDetailView)
        vc.location = location
        
        if viewController != nil {
            viewController?.present(vc, animated: true, completion: nil)
        }else {
            App().mainVC?.present(vc, animated: true, completion: nil)
        }
    }
}
