//
//  OrderDetailViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreLocation
import Photos

enum OrderDetailSection:Int {
    case sectionMap = 0
    case sectionInforDetail
    case sectionSignature
    case sectionPictures
    case sectionDescription
    
    static let count: Int = {
        var max: Int = 0
        while let _ = OrderDetailSection(rawValue: max) { max += 1 }
        return max
    }()
}


class OrderDetailViewController: BaseOrderDetailViewController {
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var updateStatusButton: UIButton?
    @IBOutlet weak var btnUnable: UIButton?
    @IBOutlet weak var vAction: UIView?
    
    fileprivate var orderInforDetail = [OrderDetailInforRow]()
    fileprivate let cellIdentifier = "OrderDetailTableViewCell"
    fileprivate let headerCellIdentifier = "OrderDetailHeaderCell"
    fileprivate let addressCellIdentifier =  "OrderDetailAddressCell"
    fileprivate let orderDropdownCellIdentifier = "OrderDetailDropdownCell"
    fileprivate let orderDetailMapCellIdentifier = "OrderDetailMapCell"
    fileprivate let orderPictureTableViewCell = "PictureTableViewCell"
    fileprivate var scanItems = [String]()
    fileprivate var arrTitleHeader:[String] = []
    
    var dateStringFilter = Date().toString()
    var btnGo: UIButton?

    override var orderDetail: Order? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        initVar()
        fetchData(showLoading: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func reachabilityChangedNetwork(_ isAvailaibleNetwork: Bool) {
        super.reachabilityChangedNetwork(isAvailaibleNetwork)
        //checkConnetionInternet?(notification, isAvailaibleNetwork)
    }
    
    override func updateUI()  {
        super.updateUI()
        DispatchQueue.main.async {[weak self] in
            self?.vAction?.isHidden = (self?.orderDetail == nil)
            self?.updateButtonStatus()
            self?.setupTableView()
        }
    }
    
    
    override func updateNavigationBar() {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Menu, "")
    }
    
    override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Detail".localized)
    }
    
    //MARK: - Initialize
    func setupTableView() {
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableView.automaticDimension
    }
    
    func initVar()  {
        arrTitleHeader = ["",
                          "ORDER INFO".localized,
                          "SIGNATURE".localized,
                          "PICTURE".localized]
        setupDataDetailInforRows()
    }
    
    func setupDataDetailInforRows() {
        orderInforDetail.removeAll()
        
        //let displayDateTimeVN = DateFormatter.displayDateTimeVN
        //let startDate = DateFormatter.serverDateFormater.date(from: _orderDetail.startTime)
        //let endDate = DateFormatter.serverDateFormater.date(from: _orderDetail.endTime)
        //        let urgency = OrderDetailInforRow("Urgency" ,isHebewLang() ? _orderDetail.urgent_type_name_hb :  _orderDetail.urgent_type_name_en)
        let zone = OrderDetailInforRow("Zone", "-")
        let containerNumber = OrderDetailInforRow("Container Number", "-")
        let sealNumber = OrderDetailInforRow("Seal Number", "-")
        let bLNumber = OrderDetailInforRow("BL Number","-")
        let statusDate = OrderDetailInforRow("Status Date", "-")
        let location = OrderDetailInforRow("Location", "-")
        let LFD = OrderDetailInforRow("LFD (Last Free Day)","-")
        let emptyContainerReturn = OrderDetailInforRow("Empty Container Return", "-")
        //let terminalHold = OrderDetailInforRow("Terminal Hold", "-")
        let containerSize = OrderDetailInforRow("Container Size","-")
        let containerType = OrderDetailInforRow("Container Type","-")
        let special = OrderDetailInforRow("Special", "-")
        let titlePortAddress = OrderDetailInforRow("Port Address:", "")
        let portAddressContent = OrderDetailInforRow("", "-",true)
        
        let titleAddress = OrderDetailInforRow("Delivery Address:", "")
        let addressContent = OrderDetailInforRow("Delivery Address", orderDetail?.to?.address ?? "-",true)
        
        // OrderInforDetail
        //orderInforStatus.append(urgency)
        
        //        if  _orderDetail.statusOrder == .cancelStatus {
        //            let reason = OrderDetailInforRow("Failure cause",_orderDetail.reason?.name ?? "-")
        //            let mess = OrderDetailInforRow("Message",_orderDetail.reason_msg ?? "-")
        //            orderInforDetail.append(reason)
        //            orderInforDetail.append(mess)
        //        }
        orderInforDetail.append(zone)
        orderInforDetail.append(containerNumber)
        orderInforDetail.append(sealNumber)
        orderInforDetail.append(bLNumber)
        orderInforDetail.append(containerSize)
        orderInforDetail.append(containerType)
        orderInforDetail.append(special)
        orderInforDetail.append(statusDate)
        orderInforDetail.append(location)
        orderInforDetail.append(LFD)
        orderInforDetail.append(emptyContainerReturn)
        orderInforDetail.append(titlePortAddress)
        orderInforDetail.append(portAddressContent)
        orderInforDetail.append(titleAddress)
        orderInforDetail.append(addressContent)
        
        tableView?.reloadData()
    }
    
    
    // MARK: - ACTION
    @IBAction func tapUpdateStatusButtonAction(_ sender: UIButton) {
        let vc:StartRouteOrderVC = StartRouteOrderVC.loadSB(SB: .Route)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleUnableToStartAction() {
        let vc:ReasonListViewController = .loadSB(SB: .Common)
        vc.orderDetail = orderDetail
        vc.didCancelSuccess =  { [weak self] (success, order) in
            //self?.fetchData(showLoading: false)
            self?.orderDetail = order as? Order
            self?.updateUI()
            self?.setupDataDetailInforRows()
            self?.tableView?.reloadData()
            self?.didUpdateStatus?((self?.orderDetail)!, nil)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleFinishAction() {
        guard let _orderDetail = orderDetail else {return}
        let status:StatusOrder = _orderDetail.statusOrder
        var statusNeedUpdate = status.rawValue
        switch status{
        case .newStatus:
            statusNeedUpdate = StatusOrder.inProcessStatus.rawValue
            updateOrderStatus(statusNeedUpdate)
            
        case .inProcessStatus:
            if _orderDetail.isRequireImage() &&
                _orderDetail.pictures?.count ?? 0 <= 0{
                self.showAlertView("Picture required".localized) {(action) in
                    //self?.didUpdateStatus?(_orderDetail, nil)
                }
                
            }else if (_orderDetail.isRequireSign() &&
                _orderDetail.signature == nil) {
                self.showAlertView("Signature required".localized) {(action) in
                    //self?.didUpdateStatus?(_orderDetail, nil)
                }
                
            }else {
                statusNeedUpdate = StatusOrder.deliveryStatus.rawValue
                self.updateOrderStatus(statusNeedUpdate)
            }
            
        default:
            break
        }
    }
    
    func showInputNote(_ statusNeedUpdate:String) {
        let alert = UIAlertController(title: "Finish order".localized,
                                      message: nil, preferredStyle: .alert)
        alert.showTextViewInput(placeholder: "Enter note for this order(optional)".localized,
                                nameAction: "Finish".localized,
                                oldText: "") {[weak self] (success, string) in
                                    //self?.orderDetail?.note = string
                                    self?.updateOrderStatus(statusNeedUpdate)
        }
    }
}


// MARK: - UITableView
extension OrderDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrTitleHeader.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let orderSection:OrderDetailSection = OrderDetailSection(rawValue: section) else {
            return 0
        }
        switch orderSection {
        case .sectionMap:
            return 1
        case .sectionInforDetail:
            return orderInforDetail.count
        case .sectionSignature:
            return orderDetail?.signature != nil ? 1 : 0
        case .sectionPictures:
            return orderDetail?.pictures?.count ?? 0
        case .sectionDescription:
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let orderSection:OrderDetailSection = OrderDetailSection(rawValue: section) else {
            return 0
        }
        switch orderSection {
        case .sectionMap:
            return 0
        default:
            return 65
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as? OrderDetailTableViewCell{
            headerCell.nameLabel?.text = arrTitleHeader[section];
            headerCell.btnEdit?.tag = section
            headerCell.delegate = self
            headerCell.btnEdit?.isHidden = true
            headerCell.btnStatus?.isHidden = true
            let orderSection:OrderDetailSection = OrderDetailSection(rawValue: section)!
            switch orderSection {
            case .sectionInforDetail:
                headerCell.btnStatus?.isHidden = false
                headerCell.btnStatus?.borderWidth = 1.0
                headerCell.btnStatus?.borderColor = AppColor.redColor
                headerCell.btnStatus?.setTitle("In progress", for: .normal)
                headerCell.btnStatus?.setTitleColor(AppColor.redColor, for: .normal)
                
            case .sectionSignature:
                var isAdd = false
                if orderDetail?.driver_id == Caches().user?.userInfo?.id &&
                    (orderDetail?.signature == nil){
                    isAdd = true
                }
                
                headerCell.btnEdit?.isHidden = !isAdd
            case .sectionPictures:
                var isAdd = false
                if orderDetail?.driver_id == Caches().user?.userInfo?.id{
                    isAdd = true
                }
                headerCell.btnEdit?.isHidden = !isAdd
            default:
                break
            }
            return headerCell;
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
        let orderSection:OrderDetailSection = OrderDetailSection(rawValue: indexPath.section)!
        switch orderSection {
        case .sectionMap:
            return cellMap(tableView,indexPath)
        case .sectionInforDetail:
            return cellInfoDetail(tableView,indexPath)
        case .sectionSignature:
            return cellSignature(tableView, indexPath)
        case .sectionPictures:
            return cellPicture(tableView,indexPath)
        case .sectionDescription:
           return cellDiscription(tableView,indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let orderSection = OrderDetailSection(rawValue:indexPath.section) else {
            return
        }
        let row = indexPath.row
        switch orderSection {
        case .sectionInforDetail:
            if row != orderInforDetail.count - 1 &&  // From address,To address
                row != orderInforDetail.count - 3 {
                return
            }
            
            let vc:OrderDetailMapViewController = .loadSB(SB: .Order)
            if row != orderInforDetail.count - 1{
                if let _orderDetail = orderDetail,
                    let lng = _orderDetail.to?.lngtd,
                    let lat = _orderDetail.to?.lattd  {
                    let location = CLLocationCoordinate2D(latitude: lat.doubleValue ,
                                                          longitude: lng.doubleValue)
                    vc.orderLocation = location
                }
                
            }else {
                //
            }
            
            //self.present(vc, animated: true, completion: nil)
            self.navigationController?.pushViewController( vc, animated: true)
            
        case .sectionSignature:
            self.showImage(nil, linkUrl: orderDetail?.signature?.url, placeHolder: nil)
            
        case .sectionPictures:
            let picture = orderDetail?.pictures?[row]
            self.showImage(nil, linkUrl: picture?.url, placeHolder: nil)
            
        default:
            break
        }
    }
}

//MARK:  - UIScrollViewDelegate
extension OrderDetailViewController:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        print("OffsetY :\(offsetY)")
        UIView.animate(withDuration: 0.7, animations: {
            if offsetY > 45 {
                self.vAction?.isHidden = false
                self.btnGo?.isHidden = true
            }else {
                self.vAction?.isHidden = true
                self.btnGo?.isHidden = false
            }
           self.vAction?.layoutIfNeeded()
            
        }) { (finished) in
            //
        }
    }
}

//MARK: - CELL FUNTION
fileprivate extension OrderDetailViewController {
    func cellMap(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: orderDetailMapCellIdentifier, for: indexPath) as! OrderDetailTableViewCell
        cell.delegate = self
        btnGo = cell.btnGo
        return cell
    }
    
    func cellInfoDetail(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let item = orderInforDetail[indexPath.row]
        var identifier = cellIdentifier
        if indexPath.row == orderInforDetail.count - 1 ||
            indexPath.row == orderInforDetail.count - 3{
            identifier = addressCellIdentifier
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OrderDetailTableViewCell
        cell.orderDetailItem = item
        cell.selectionStyle = .none
        cell.vContent?.noRoundCornersLRT()
        
        if indexPath.row == orderInforDetail.count - 1 ||
            indexPath.row == orderInforDetail.count - 3{
            cell.iconImgView?.isHidden = false
            if indexPath.row == orderInforDetail.count - 1 {
                cell.vContent?.roundCornersLRB()
            }
            
        }else {
            cell.iconImgView?.isHidden = true
        }
        return cell
    }
    
    func cellSignature(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: orderPictureTableViewCell,
                                                 for: indexPath) as! PictureTableViewCell
        cell.selectionStyle = .none
        if let sig =  orderDetail?.signature {
            cell.nameLabel.text = sig.name
            if sig.url_thumbnail != nil {
                cell.imgView.sd_setImage(with: URL(string: E(sig.url_thumbnail)),
                                         placeholderImage: #imageLiteral(resourceName: "place_holder"),
                                         options: .refreshCached, completed: nil)
            }else {
                cell.imgView.image = UIImage(data: sig.contentFile ?? Data())
            }
        }
        cell.selectionStyle = .none
        cell.vContent?.roundCornersLRB()
        return cell
    }
    
    func cellPicture(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: orderPictureTableViewCell, for: indexPath) as! PictureTableViewCell
        cell.imgView.image = nil
        if let picture =  orderDetail?.pictures?[indexPath.row] {
            cell.nameLabel.text = picture.name
            if picture.url != nil {
                cell.imgView.sd_setImage(with: URL(string: E(picture.urlS3)),
                                         placeholderImage: #imageLiteral(resourceName: "place_holder"),
                                         options: .refreshCached, completed: nil)
            }else {
                cell.imgView.image = UIImage(data: picture.contentFile ?? Data())
            }
        }
        
        let countPicture = orderDetail?.pictures?.count ?? 0
        if indexPath.row == (countPicture - 1) {
            cell.vContent?.roundCornersLRB()
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func cellDiscription(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: addressCellIdentifier, for: indexPath) as! OrderDetailTableViewCell
        let description = OrderDetailInforRow("Instructions","-")
        cell.orderDetailItem = description
        cell.selectionStyle = .none
        cell.vContent?.roundCornersLRB()
        
        return cell
    }
}

extension OrderDetailViewController:DMSNavigationServiceDelegate {
    func didSelectedBackOrMenu() {
        showSideMenu()
    }
}


//MARK: - OrderDetailTableViewCellDelegate
extension OrderDetailViewController: OrderDetailTableViewCellDelegate {
    func didSelectGo(_ cell: OrderDetailTableViewCell, _ btn: UIButton) {
        let vc:StartRouteOrderVC = StartRouteOrderVC.loadSB(SB: .Route)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didSelectedDopdown(_ cell: OrderDetailTableViewCell, _ btn: UIButton) {
        //
    }
    
    func didSelectEdit(_ cell: OrderDetailTableViewCell, _ btn: UIButton) {
        guard let orderSection = OrderDetailSection(rawValue:btn.tag) else {
            return
        }
        switch orderSection {
        case .sectionPictures:
            doAddPictures()
        case .sectionSignature:
            doAddSignature()
        default:
            break
        }
    }
    
    func doAddSignature()  {
        let vc:OrderSignatureViewController = OrderSignatureViewController.loadSB(SB: .Order)
        vc.orderDetail = orderDetail
        vc.updateOrderDetail = {[weak self](order) in
            self?.fetchData(showLoading: false)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func doAddPictures() {
        ImagePickerView.shared().showImageGallarySinglePick(atVC: self) { (success, data) in
            if let _data = data as? [PHAsset] {
                var arrAttachfile:[AttachFileModel] = []
                
                for i in 0..<_data.count{
                    let image:UIImage = self.getAssetThumbnail(asset: _data[i], size: ScreenSize.SCREEN_HEIGHT)
                    if let data = image.jpegData(compressionQuality: 0.75) {
                        let file: AttachFileModel = AttachFileModel()
                        file.name = E(_data[i].originalFilename)
                        file.type = ".png"
                        file.mimeType = "image/png"
                        file.contentFile = data
                        file.param = "file_pod_req[\(i)]"
                        arrAttachfile.append(file)
                        
                    }else {
                        print("encode failure")
                    }
                }
                
                if arrAttachfile.count > 0{
                    self.uploadMultipleFile(files: arrAttachfile)
                }
                
            }else if let image = data as? UIImage {
                if let data = image.jpegData(compressionQuality: 0.75) {
                    let file: AttachFileModel = AttachFileModel()
                    file.name = "Picture_\(Date().timeIntervalSince1970)"
                    file.type = ".png"
                    file.mimeType = "image/png"
                    file.contentFile = data
                    file.param = "file_pod_req[0]"
                    self.uploadMultipleFile(files: [file])
                    
                }else {
                    print("encode failure")
                }
            }
        }
    }
}


//MARK: - Otherfuntion
fileprivate extension OrderDetailViewController{
    func scrollToBottom(){
        DispatchQueue.main.async {[weak self] in
            let indexPath = IndexPath(row: 0, section: OrderDetailSection.sectionDescription.rawValue)
            self?.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func updateButtonStatus() {
        updateStatusButton?.backgroundColor = AppColor.buttonColor
        vAction?.isHidden = true
        /*
        let driverId = orderDetail?.driver_id
        if driverId == Caches().user?.userInfo?.id {
            guard let statusOrder = orderDetail?.statusOrder else {return}
            switch statusOrder {
            case .newStatus:
                vAction?.isHidden = false
                updateStatusButton?.setTitle("Start".localized.uppercased(), for: .normal)
                btnUnable?.setTitle("Unable To Start".localized.uppercased(), for: .normal)
                
            case .inProcessStatus:
                vAction?.isHidden = false
                updateStatusButton?.setTitle("Finish".localized.uppercased(), for: .normal)
                btnUnable?.setTitle("Unable To Finish".localized.uppercased(), for: .normal)
                
            default:
                break
            }
        }
         */
    }
    
    func getAssetThumbnail(asset: PHAsset, size: CGFloat) -> UIImage {
        let retinaScale = UIScreen.main.scale
        let retinaSquare = CGSize(width: size * retinaScale, height: size * retinaScale)
        
        let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
        let square = CGRect(x: 0, y: 0, width: CGFloat(cropSizeLength), height:  CGFloat(cropSizeLength))
        
        let cropRect = square.applying(CGAffineTransform(scaleX: 1.0/CGFloat(asset.pixelWidth), y: 1.0/CGFloat(asset.pixelHeight)))
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        var thumbnail = UIImage()
        
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.normalizedCropRect = cropRect
        
        manager.requestImage(for: asset, targetSize: retinaSquare, contentMode: .aspectFit, options: options, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
}

//MARK: API
extension OrderDetailViewController{
    func fetchData(showLoading:Bool = false)  {
        getOrderDetail()
    }
    
    private func getOrderDetail(isFetch:Bool = false) {
        if hasNetworkConnection &&
            ReachabilityManager.isCalling == false {
            guard let _orderID = orderDetail?.id else { return }
            if !isFetch {
                showLoadingIndicator()
            }
            SERVICES().API.getOrderDetail(orderId: "\(_orderID)") {[weak self] (result) in
                self?.dismissLoadingIndicator()
                switch result{
                case .object(let object):
                    self?.orderDetail = object.data
                    self?.rootVC?.order =  self?.orderDetail
                    self?.initVar()
                    self?.updateUI()
                    //CoreDataManager.updateOrderDetail(object) // update orderdetail to DB local
                    
                case .error(let error):
                    self?.showAlertView(error.getMessage())
                }
            }
            
        }else {
            
            //Get data from local DB
            /*
             if let _order = self.orderDetail{
             CoreDataManager.queryOrderDetail(_order.id, callback: {[weak self] (success,data) in
             guard let strongSelf = self else{return}
             strongSelf.orderDetail = data
             strongSelf.updateUI()
             })
             }
             */
        }
    }
    
    func updateOrderStatus(_ statusCode: String) {
        guard let _orderDetail = orderDetail else {
            return
        }
        let listStatus =  CoreDataManager.getListStatus()
        for item in listStatus {
            if item.code == statusCode{
                _orderDetail.status = item
                break
            }
        }
        
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        updateOrderStatusImport(_orderDetail)
    }
    
    
    func updateOrderStatusImport(_ order:Order)  {
        SERVICES().API.updateOrderStatus(order) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.setupDataDetailInforRows()
                self?.updateButtonStatus()
                self?.tableView?.reloadData()
                self?.didUpdateStatus?(order, nil)
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    func uploadMultipleFile(files:[AttachFileModel]){
        guard let order = orderDetail else { return }
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        SERVICES().API.uploadMultipleImageToOrder(files, order) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.fetchData()
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    func updateRoute()  {
        for i in 0..<(self.route?.orderList.count ?? 0) {
            if self.route?.orderList[i].id == self.orderDetail?.id {
                self.route?.orderList[i] = (self.orderDetail)!
                break
            }
        }
    }
    
    func assignOrderToDriver(_ requestAssignOrder:RequestAssignOrderModel)  {
        self.showLoadingIndicator()
        SERVICES().API.assignOrderToDriver(body: requestAssignOrder) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.updateOrderDetail?(self?.orderDetail)
                self?.showAlertView("Assigned successfull.".localized,
                                    completionHandler: { (ok) in
                                        /*
                                        let vc:JobListVC = .loadSB(SB: .Job)
                                        vc.dateStringFilter = E(self?.dateStringFilter)
                                        App().mainVC?.rootNV?.setViewControllers([vc], animated: false)
                                         */
                })
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}

