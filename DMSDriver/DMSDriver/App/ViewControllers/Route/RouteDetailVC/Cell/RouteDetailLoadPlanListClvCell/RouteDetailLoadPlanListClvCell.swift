//
//  RouteDetailLoadPlanListClvCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/27/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol RouteDetailLoadPlanListClvCellDelegate: class {
    func didBeginEditSearchText()
    func didEndEditSearchText()
}

class RouteDetailLoadPlanListClvCell: UICollectionViewCell {
    weak var delegate: RouteDetailLoadPlanListClvCellDelegate?
    
    @IBOutlet weak var tbvContent: UITableView?
    @IBOutlet weak var platenumLbl: UILabel!
    @IBOutlet weak var maxVolumeLbl: UILabel!
    @IBOutlet weak var tachographLbl: UILabel!
    @IBOutlet weak var routeTypeLbl: UILabel!
    @IBOutlet weak var tachographView: UIView!
    @IBOutlet weak var loadplanInfoView: UIStackView!
    @IBOutlet weak var loadPlanInfoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var platenumBtn: UIButton!
    @IBOutlet weak var iconPlatenumBtn: UIButton!
    
    @IBOutlet weak var iconDropDownWeightConstant: NSLayoutConstraint!
    @IBOutlet weak var loadplanHeaderView: UIView!
    
    @IBOutlet weak var maxVolumeViewContainer: UIView!
    
    @IBOutlet weak var numberOfPalletsViewContainer: UIView!
    
    @IBOutlet weak var numberOfPalletLabel: UILabel!
    let LOAD_PLAN_VIEW_HEIGHT:CGFloat = 130.0
    let LOAD_PLAN_VIEW_HEIGHT_TACHOGRAPH:CGFloat = 160.0
    
    
    fileprivate let headerCellIdentifier = "RouteDetailLoadPlanHeaderTbvCell"
    fileprivate let itemCellIdentifier = "RouteDetailLoadPlanItemTbvCell"
    private var groupLocationList:[GroupLocatonModel] = []
    private var HEIGHT_HEADER:CGFloat = 40
    
    var route: Route? {
        didSet {
            initVar()
        }
    }
    
    weak var rootVC: RouteDetailVC?
    var dataDisplay:Truck?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
        tbvContent?.backgroundColor = UIColor.clear
    }
    
    func initVar() {
        guard let _routeTypeId = route?.routeType?.id else { return }
        let routeType:Route.RouteType = Route.RouteType(rawValue: _routeTypeId)!
        switch routeType {
        case .Liquid:
            dataDisplay = route?.tankers?.first
        case .Packed:
            dataDisplay = route?.truck
        }
        updateUI()
    }
    
    func updateUI() {
        guard let _route = route else { return }
        let isLiquid = route?.routeType?.id == Route.RouteType.Liquid.rawValue
        let isTachograph = (dataDisplay?.type?.isTachograph() ?? false)
        platenumLbl.textColor = isLiquid ? AppColor.greenColor : .black
        platenumBtn.isEnabled = isLiquid
        iconPlatenumBtn.tintColor = AppColor.greenColor
        iconPlatenumBtn.isHidden = !isLiquid
        tachographView.isHidden = !isTachograph
        loadPlanInfoHeightConstraint.constant = isTachograph ? LOAD_PLAN_VIEW_HEIGHT_TACHOGRAPH : LOAD_PLAN_VIEW_HEIGHT
        scrollViewHeightConstraint.constant = estimateHeightForTableView()
        loadplanHeaderView.roundCornersLRT()
        loadplanInfoView.roundCornersLRB()
        iconDropDownWeightConstant.constant = isLiquid ? 7.5 : 0
        
        platenumLbl.text = Slash(dataDisplay?.plateNumber)
        
        tachographLbl.text = (dataDisplay?.type?.isTachograph() ?? false) ? "yes".localized : "no".localized
        routeTypeLbl.text = route?.routeTypeName()
        
        if _route.isLiquidType {
            maxVolumeViewContainer.isHidden = false
            maxVolumeLbl.text = Slash(dataDisplay?.maxVolumeName)
        } else {
            numberOfPalletsViewContainer.isHidden = false
            numberOfPalletLabel.text = IntSlash(_route.numberOfPallets) 
        }
    }
    
    func setupTableView() {
        tbvContent?.delegate = self
        tbvContent?.dataSource = self
    }
    
    // We need estimate Height due to missing accuracy height of frame for scroll view
    private func estimateHeightForTableView() -> CGFloat {
        var accuracyHeight:CGFloat = 0
        let numberOfSection = dataDisplay?.compartments?.count ?? 0
        for section in 0..<numberOfSection {
            let numberOfCompartmentDetails = dataDisplay?.compartments?[section].detail?.count ?? 0
            accuracyHeight = CGFloat(numberOfCompartmentDetails*40) + accuracyHeight // change the value multiplier to adjust the accuracy you want
        }
        let missingHeightForSpaceLine:CGFloat = CGFloat(8*(numberOfSection - 1))
        accuracyHeight = CGFloat(numberOfSection*50) + accuracyHeight + missingHeightForSpaceLine
        
        let height = loadPlanInfoHeightConstraint.constant + accuracyHeight
        return height
    }
    
    @IBAction func didTapPlatenumBtn(sender: UIButton) {
        guard let _tankers = route?.tankers else { return }
        let item = DropDownModel().addTruck(_tankers)
        let vc = DropDownViewController()
        vc.titleContent = "plate-number".localized.uppercased()
        vc.dropDownType = .PlateNumber
        vc.itemDropDown = item
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        App().window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
}

//MARK: - RouteDetailOrderListClvCell,UITableViewDataSource
extension RouteDetailLoadPlanListClvCell: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataDisplay?.compartments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataDisplay?.compartments?[section].detail?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HEIGHT_HEADER
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let routeTypeId = route?.routeType?.id ,let _compartment = dataDisplay?.compartments?[section], let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as? RouteDetailLoadPlanHeaderTbvCell{
            
            guard let routeType:Route.RouteType = Route.RouteType(rawValue: routeTypeId) else { return nil }
            switch routeType {
            case .Liquid:
                headerCell.configureHeaderLiquidType(_compartment)
            case .Packed:
                headerCell.configureHeaderPackedType(_compartment)
            }
            let headerView = UIView()
            headerView.addSubview(headerCell)
            headerCell.frame = CGRect(x: 0, y: 0, width: (tbvContent?.frame.width ?? 0), height: HEIGHT_HEADER)
            headerView.roundCornersLRT()
            return headerView;
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view:UIView = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let _compartmentDetail = dataDisplay?.compartments?[indexPath.section].detail?[indexPath.row], let itemCell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier) as? RouteDetailLoadPlanItemTbvCell{
        
            let routeType:Route.RouteType = Route.RouteType(rawValue: (route?.routeType?.id ?? 0))!
            switch routeType {
            case .Liquid:
                itemCell.configureLiquid(_compartmentDetail)
            case .Packed:
                itemCell.configurePacked(_compartmentDetail)
            }
            let isLastCell = dataDisplay?.compartments?[indexPath.section].detail?.count == (indexPath.row + 1)
            if isLastCell {
                itemCell.roundCornersLRB()
            }
            return itemCell
        }
        return UITableViewCell()
    }
}

extension RouteDetailLoadPlanListClvCell: DropDownViewControllerDelegate {
    func didSelectItem(item: DropDownModel) {
        guard let _tanker = item.truck?.first else { return }
        dataDisplay = _tanker
        self.updateUI()
        self.tbvContent?.reloadData()
    }
}
