//
//  PackagesViewController.swift
//  DMSDriver
//
//  Created by Nguyen Phu on 4/6/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class PackagesViewController: BaseViewController {
    
    enum SectionPackage:Int {
        case dilevery = 0
        case backHoul
        case packageTruck
    }
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var lblNodata: UILabel?

  fileprivate let cellIdentifier = "PackageTableViewCell"
  fileprivate let headerIdentifier = "PackageHeaderCell"

  fileprivate let cellHeight: CGFloat = 40.0
  fileprivate let headerHeight: CGFloat = 70.0
  fileprivate let footerHeight: CGFloat = 20.0


    
  fileprivate var package: PackageModel = PackageModel()
  var route: Route?
  var dateStringFilter:String = Date().toString()
    
  fileprivate let titleHeaders = ["Delivery".localized.uppercased(),
                                  "Pick Up".localized.uppercased(),
                                  "Package On Truck".localized.uppercased()]
    
  fileprivate var dileveryDatas:[[String]] = []
  fileprivate var backHaulDatas:[[String]] = []
  fileprivate var packageOnTruckDatas:[[String]] = []

    
  override func viewDidLoad() {
    super.viewDidLoad()
    
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPackages()
    }
    
    func setupData() {

        dileveryDatas = [["Total double type".localized,"\(package.delivery.total_double_type)"],
                         ["Total cartons".localized,"\(package.delivery.total_cartons)"],
                         ["Total packages".localized,"\(package.delivery.total_packages)"],
                         ["Double type complete".localized,"\(package.delivery.double_type_complete)"],
                         ["Packages complete".localized,"\(package.delivery.packages_complete)"],
                         ["Cartons complete".localized,"\(package.delivery.cartons_complete)"],
                         ["Double type not complete".localized,"\(package.delivery.double_type_not_complete)"],
                         ["Cartons not complete".localized,"\(package.delivery.cartons_not_complete)"],
                         ["Packages not complete".localized,"\(package.delivery.packages_not_complete)"]]
        
        backHaulDatas = [["Total double type".localized,"\(package.back_haul.total_double_type)"],
                         ["Total cartons".localized,"\(package.back_haul.total_cartons)"],
                         ["Total packages".localized,"\(package.back_haul.total_packages)"],
                         ["Double type complete".localized,"\(package.back_haul.double_type_complete)"],
                         ["Packages complete".localized,"\(package.back_haul.packages_complete)"],
                         ["Cartons complete".localized,"\(package.back_haul.cartons_complete)"],
                         ["Double type not complete".localized,"\(package.back_haul.double_type_not_complete)"],
                         ["Cartons not complete".localized,"\(package.back_haul.cartons_not_complete)"],
                         ["Packages not complete".localized,"\(package.back_haul.packages_not_complete)"]]
        
        
        packageOnTruckDatas = [["Total double type".localized,"\(package.package_on_truck.totalDoubleType)"],
                               ["Total cartons".localized,"\(package.package_on_truck.totalCartons)"],
                               ["Total packages".localized,"\(package.package_on_truck.totalPackages)"]]
        
    }
}

extension PackagesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionPK = SectionPackage(rawValue: section)
        switch sectionPK! {
        case .dilevery:
            return dileveryDatas.count
        case .backHoul:
            return dileveryDatas.count
        case .packageTruck:
            return packageOnTruckDatas.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight.scaleHeight()

    }
 
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerHeight.scaleHeight()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight.scaleHeight()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell:PackageTableViewCell = tableView.dequeueReusableCell(withIdentifier: headerIdentifier) as! PackageTableViewCell
        
        headerCell.lblKey?.text = titleHeaders[section]
        return headerCell
    }
    
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PackageTableViewCell
            else {
            return UITableViewCell()
        }

        let sectionPK = SectionPackage(rawValue: indexPath.section)
        let row = indexPath.row

        switch sectionPK! {
        case .dilevery:
            cell.configura(E(dileveryDatas[row].first), E(dileveryDatas[row].last))
        case .backHoul:
            cell.configura(E(backHaulDatas[row].first), E(backHaulDatas[row].last))
        case .packageTruck:
            cell.configura(E(packageOnTruckDatas[row].first), E(packageOnTruckDatas[row].last))
        }

        return cell
    }

  
}


//MARK : - PackagesViewController
extension PackagesViewController{
    
    func getPackages() {
        guard let route = route else {return}
        self.showLoadingIndicator()
        API().getPackagesInRoute("\(route.id)", dateStringFilter) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(let obj):
                if let  packages =  obj.data {
                    self?.package = packages
                    self?.setupData()
                    self?.tableView.reloadData()
                }
                break
            case .error(let error):
                self?.showAlertView(error.getMessage())
                break
            }
        }
    }
}
