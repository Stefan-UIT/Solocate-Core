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
    case sectionOrderInfo
    case sectionFrom
    case sectionTo
    case sectionNatureOfGoods
    case sectionSignature
    case sectionPictures
    case sectionDescription
    
    static let count: Int = {
        var max: Int = 0
        while let _ = OrderDetailSection(rawValue: max) { max += 1 }
        return max
    }()
}

typealias UpdateOrderDetailCallback = (Bool,Order) -> Void

class OrderDetailViewController: BaseOrderDetailViewController {
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var updateStatusButton: UIButton?
    @IBOutlet weak var btnUnable: UIButton?
    @IBOutlet weak var vAction: UIView?
    @IBOutlet weak var lblOrderId: UILabel?
    @IBOutlet weak var lblDateTime: UILabel?

    fileprivate var orderInforDetail = [OrderDetailInforRow]()
    fileprivate var orderInforFrom = [OrderDetailInforRow]()
    fileprivate var orderInforTo = [OrderDetailInforRow]()
    fileprivate var orderInforNatureOfGoods = [OrderDetailInforRow]()
    fileprivate let cellIdentifier = "OrderDetailTableViewCell"
    fileprivate let headerCellIdentifier = "OrderDetailHeaderCell"
    fileprivate let addressCellIdentifier =  "OrderDetailAddressCell"
    fileprivate let orderDropdownCellIdentifier = "OrderDetailDropdownCell"
    fileprivate let orderDetailMapCellIdentifier = "OrderDetailMapCell"
    fileprivate let orderPictureTableViewCell = "PictureTableViewCell"
    fileprivate let orderDetailNatureOfGoodsCell = "OrderDetailNatureOfGoodsCell"

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
            self?.initUI()
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
    private func setupTableView() {
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableView.automaticDimension
    }
    
    private func initVar()  {
        arrTitleHeader = ["",
                          "Order info".localized.uppercased(),
                          "From".localized.uppercased(),
                          "To".localized.uppercased(),
                          "Nature of goods".localized.uppercased(),
                          "Signature".localized.uppercased(),
                          "Picture".localized.uppercased()]
        setupDataDetailInforRows()
    }
    
    private func initUI()  {
        lblOrderId?.text = "Delivery #\(orderDetail?.id ?? 0)"
        guard  let start = orderDetail?.to?.start_time?.date,
               let end = orderDetail?.to?.end_time?.date else{
            lblDateTime?.text = "Start/End time is invalid."
            return
        }
        let timeStart = DateFormatter.hour24Formater.string(from: start)
        let timeEnd = DateFormatter.hour24Formater.string(from: end)
        let date = DateFormatter.shortDate.string(from: end)
        lblDateTime?.text = "\(timeStart) - \(timeEnd) \(date)"
    }
    
    private func setupDataDetailInforRows() {
        orderInforDetail.removeAll()
        orderInforFrom.removeAll()
        orderInforTo.removeAll()
        orderInforNatureOfGoods.removeAll()

        let displayDateTimeVN = DateFormatter.displayDateTimeVN
        var startFromDate = ""
        if let date = orderDetail?.from?.start_time?.date {
            startFromDate = displayDateTimeVN.string(from: date)
        }else {
            startFromDate = "Invalid date."
        }
        
        var endFromDate = ""
        if let date = orderDetail?.from?.end_time?.date {
            endFromDate = displayDateTimeVN.string(from: date)
        }else {
            endFromDate = "Invalid date."
        }
        
        var startToDate = ""
        if let date = orderDetail?.to?.start_time?.date {
            startToDate = displayDateTimeVN.string(from: date)
        }else {
            startToDate = "Invalid date."
        }
        
        var endToDate = ""
        if let date = orderDetail?.to?.end_time?.date {
            endToDate = displayDateTimeVN.string(from: date)
        }else {
            endToDate = "Invalid date."
        }
        
        let status = StatusOrder(rawValue: orderDetail?.statusCode ?? "") ?? StatusOrder.newStatus
        let statusItem = OrderDetailInforRow("Status".localized,status.statusName)
        let customerItem = OrderDetailInforRow("Customer Name".localized.localized,
                                             orderDetail?.custumer_name ?? "-")
        let urgency = OrderDetailInforRow("Urgency".localized,
                                          isHebewLang() ? orderDetail?.urgent_type_name_hb ?? "" :  orderDetail?.urgent_type_name_en ?? "")
        let orderId = OrderDetailInforRow("Order Id".localized,"#\(orderDetail?.id ?? 0)")
        let seq = OrderDetailInforRow("SEQ".localized,"\(orderDetail?.seq ?? 0)")
        
        orderInforDetail.append(orderId)
        orderInforDetail.append(seq)
        orderInforDetail.append(customerItem)
        //orderInforStatus.append(urgency)
        
        if  (orderDetail?.statusOrder == .cancelStatus ||
             orderDetail?.statusOrder == .cancelFinishStatus),
            let _orderDetail = orderDetail{
            let reason = OrderDetailInforRow("Failure cause".localized,_orderDetail.reason?.name ?? "-")
            let mess = OrderDetailInforRow("Message".localized,_orderDetail.reason_msg ?? "-")
            orderInforDetail.append(reason)
            orderInforDetail.append(mess)
        }
        
        let fromAddress = OrderDetailInforRow("From address".localized, E(orderDetail?.from?.address),true)
        let fromContactName = OrderDetailInforRow("Contact name".localized,orderDetail?.from?.name ?? "-")
        let fromContactPhone = OrderDetailInforRow("Contact phone".localized,orderDetail?.from?.phone ?? "-",true)
        let fromStartTime = OrderDetailInforRow("Start time".localized,startFromDate,false)
        let fromEndtime = OrderDetailInforRow("End time".localized,endFromDate,false)

        let toAddress = OrderDetailInforRow("To address".localized, E(orderDetail?.to?.address),true)
        let toContactName = OrderDetailInforRow("Contact name".localized,orderDetail?.to?.name ?? "-")
        let toContactPhone = OrderDetailInforRow("Contact phone".localized,orderDetail?.to?.phone ?? "-", true)
        let toStartTime = OrderDetailInforRow("Start time".localized,startToDate,false)
        let tomEndtime = OrderDetailInforRow("End time".localized,endToDate,false)

        orderInforFrom.append(fromAddress)
        orderInforFrom.append(fromContactName)
        orderInforFrom.append(fromContactPhone)
        orderInforFrom.append(fromStartTime)
        orderInforFrom.append(fromEndtime)

        orderInforTo.append(toAddress)
        orderInforTo.append(toContactName)
        orderInforTo.append(toContactPhone)
        orderInforTo.append(toStartTime)
        orderInforTo.append(tomEndtime)

        tableView?.reloadData()
    }
    
    
    // MARK: - ACTION
    @IBAction func tapUpdateStatusButtonAction(_ sender: UIButton) {
        let vc:StartRouteOrderVC = StartRouteOrderVC.loadSB(SB: .Route)
        vc.order = orderDetail
        vc.callback = {[weak self](success, order) in
            self?.orderDetail = order
            self?.setupDataDetailInforRows()
            self?.tableView?.reloadData()
            self?.updateOrderDetail?(order)
        }
        self.navigationController?.pushViewController(vc, animated: true)
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
        case .sectionOrderInfo:
            return orderInforDetail.count
        case .sectionFrom:
            return orderInforFrom.count
        case .sectionTo:
            return orderInforTo.count
        case .sectionNatureOfGoods:
            return orderDetail?.details?.count ?? 0
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
            case .sectionOrderInfo:
                headerCell.btnStatus?.isHidden = false
                headerCell.btnStatus?.borderWidth = 1.0
                headerCell.btnStatus?.borderColor = orderDetail?.colorStatus
                headerCell.btnStatus?.setTitle(orderDetail?.status?.name, for: .normal)
                headerCell.btnStatus?.setTitleColor(orderDetail?.colorStatus, for: .normal)
                
            case .sectionSignature:
                var isAdd = false
                if (orderDetail?.signature == nil &&
                    orderDetail?.route?.driverId == Caches().user?.userInfo?.id){
                    isAdd = true
                }
                
                headerCell.btnEdit?.isHidden = !isAdd
            case .sectionPictures:
                var isAdd = false
                if orderDetail?.route?.driverId == Caches().user?.userInfo?.id &&
                        (orderDetail?.statusOrder == StatusOrder.newStatus ||
                         orderDetail?.statusOrder == StatusOrder.inProcessStatus){
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
        case .sectionOrderInfo:
            return cellInfoDetail(tableView,indexPath)
        case .sectionFrom:
            return cellInfoFromSection(tableView,indexPath)
        case .sectionTo:
            return cellInfoToSection(tableView,indexPath)
        case .sectionNatureOfGoods:
            return cellNatureOfGood(tableView,indexPath)
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
        case .sectionFrom:
            if row != 0 &&  // From address, Contact phone
                row != orderInforFrom.count - 3 {
                return
            }
            
            if row == 0{ //From address
                let vc:OrderDetailMapViewController = .loadSB(SB: .Order)
                vc.orderDetail = orderDetail
                if let _orderDetail = orderDetail,
                    let lng = _orderDetail.from?.lngtd,
                    let lat = _orderDetail.from?.lattd  {
                    let location = CLLocationCoordinate2D(latitude: lat.doubleValue ,
                                                          longitude: lng.doubleValue)
                    vc.orderLocation = location
                }
                
                self.navigationController?.pushViewController( vc, animated: true)

            }else {
                let item = orderInforFrom[row]
                callPhone(phone: item.content)
            }
            
        case .sectionTo:
            if row != 0 &&  // To address, Contact phone
                row != orderInforTo.count - 3 {
                return
            }
            
            if row == 0{
                let vc:OrderDetailMapViewController = .loadSB(SB: .Order)
                vc.orderDetail = orderDetail

                if let _orderDetail = orderDetail,
                    let lng = _orderDetail.to?.lngtd,
                    let lat = _orderDetail.to?.lattd  {
                    let location = CLLocationCoordinate2D(latitude: lat.doubleValue ,
                                                          longitude: lng.doubleValue)
                    vc.orderLocation = location
                }
                self.navigationController?.pushViewController( vc, animated: true)
                
            }else {
                let item = orderInforTo[row]
                callPhone(phone: item.content)
            }
            
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
        if orderDetail?.statusOrder != StatusOrder.newStatus &&
            orderDetail?.statusOrder != StatusOrder.inProcessStatus {
            return
        }
        
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
        cell.btnGo?.isHidden = (orderDetail?.statusOrder != StatusOrder.newStatus &&
                                orderDetail?.statusOrder != StatusOrder.inProcessStatus)
        btnGo = cell.btnGo
        cell.nameLabel?.text = orderDetail?.to?.address
        cell.drawRouteMap(order: orderDetail)
        return cell
    }
    
    func cellInfoFromSection(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let item = orderInforFrom[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                    for: indexPath) as! OrderDetailTableViewCell
        cell.orderDetailItem = item
        cell.delegate = self
        cell.selectionStyle = .none
        cell.vContent?.cornerRadius = 0
        if indexPath.row == orderInforFrom.count - 1{
            cell.vContent?.roundCornersLRB()
        }
        return cell
    }
    
    func cellInfoToSection(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let item = orderInforTo[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OrderDetailTableViewCell
        cell.orderDetailItem = item
        cell.selectionStyle = .none
        cell.vContent?.cornerRadius = 0
        if indexPath.row == orderInforTo.count - 1{
            cell.vContent?.roundCornersLRB()
        }
        return cell
  
    }
    
    func cellNatureOfGood(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let cell = tableView.dequeueReusableCell(withIdentifier: orderDetailNatureOfGoodsCell,
                                                    for: indexPath) as! OrderDetailTableViewCell
        cell.selectionStyle = .none
        
        let detail = orderDetail?.details?[indexPath.row]
        cell.nameLabel?.text = detail?.package
        cell.contentLabel?.text = "\(detail?.qty ?? 0)"
        cell.vContent?.cornerRadius = 0
        if indexPath.row == (orderDetail?.details?.count ?? 0 ) - 1{
            cell.vContent?.roundCornersLRB()
        }
        return cell
    }
    
    func cellInfoDetail(_ tableView:UITableView, _ indexPath:IndexPath) -> UITableViewCell  {
        let item = orderInforDetail[indexPath.row]
  
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OrderDetailTableViewCell
        cell.orderDetailItem = item
        cell.selectionStyle = .none
        cell.vContent?.noRoundCornersLRT()
        if indexPath.row == orderInforDetail.count - 1 {
            cell.vContent?.roundCornersLRB()
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
        vc.order  = orderDetail
        vc.callback = {[weak self](success, order) in
            self?.orderDetail = order
            self?.setupDataDetailInforRows()
            self?.tableView?.reloadData()
            self?.updateOrderDetail?(order)
        }
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
        let viewController = SignatureViewController()
        viewController.isFromOrderDetail = true
        viewController.delegate = self
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    func doAddPictures() {
        ImagePickerView.shared().showImageGallarySinglePick(atVC: self) {[weak self] (success, data) in
            if data.count > 0{
                self?.uploadMultipleFile(files: data)
            }
        }
    }
}


//MARK: - SignatureViewControllerDelegate
extension OrderDetailViewController:SignatureViewControllerDelegate{
    func signatureViewController(view: SignatureViewController, didCompletedSignature signature: AttachFileModel?) {
        if let sig = signature {
            submitSignature(sig)
        }
    }
}


//MARK: - Otherfuntion
fileprivate extension OrderDetailViewController{
    private func handleUnableToStartAction() {
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
    
    private func handleFinishAction() {
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
    
    private func showInputNote(_ statusNeedUpdate:String) {
        let alert = UIAlertController(title: "Finish order".localized,
                                      message: nil, preferredStyle: .alert)
        alert.showTextViewInput(placeholder: "Enter note for this order(optional)".localized,
                                nameAction: "Finish".localized,
                                oldText: "") {[weak self] (success, string) in
                                    //self?.orderDetail?.note = string
                                    self?.updateOrderStatus(statusNeedUpdate)
        }
    }
    
    private func callPhone(phone:String) {
        if !isEmpty(phone){
            let urlString = "tel://\(phone)"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }else {
            print("Phone number is invalid.")
        }
    }
    
    private func scrollToBottom(){
        DispatchQueue.main.async {[weak self] in
            let indexPath = IndexPath(row: 0, section: OrderDetailSection.sectionDescription.rawValue)
            self?.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    private func updateButtonStatus() {
        updateStatusButton?.backgroundColor = AppColor.buttonColor
        vAction?.isHidden = (orderDetail?.statusOrder == StatusOrder.deliveryStatus ||
                            orderDetail?.statusOrder == StatusOrder.cancelStatus ||
                            orderDetail?.statusOrder == StatusOrder.cancelFinishStatus)
    }
    
    private func getAssetThumbnail(asset: PHAsset, size: CGFloat) -> UIImage {
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
    
    func submitSignature(_ file: AttachFileModel) {
        guard let order = orderDetail else { return }
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        SERVICES().API.submitSignature(file,order) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.fetchData()
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
                break
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

