//
//  OrderPictureViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import Photos
import XLPagerTabStrip
import SDWebImage

class OrderPictureViewController: BaseOrderDetailViewController, UINavigationControllerDelegate {
    
    fileprivate let cellIdentifier = "PictureTableViewCell"
    fileprivate var imgTitle = ""
    fileprivate let cellHeight: CGFloat = 90.0
    fileprivate let headerHeight: CGFloat = 40.0
    
    fileprivate var selectedPictures = Array<PictureObject>()
    fileprivate var attachFiles = Array<AttachFileModel>()

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var btnShowImage: UIButton!
    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var vNoImage: UIView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
        upateUI()
    }
    
    func initData()  {
        attachFiles = orderDetail?.url?.doc ?? []
    }
    
    func upateUI() {
        if let _orderDetail = orderDetail {
            let isAlreadyUploadedPictures = _orderDetail.url?.doc?.count > 0
            vNoImage?.isHidden = isAlreadyUploadedPictures
            vNoImage?.isHidden = (_orderDetail.url?.doc?.count > 0)
            btnShowImage.setTitle("\("Order Id".localized) - \(_orderDetail.id)(\(attachFiles.count) \("items".localized))", for: .normal)
        }
    }
    
    
    @IBAction func takePicture(_ sender: UIButton) {
        ImagePickerView.shared().showImageGallarySinglePick(atVC: self) { (success, data) in
            if let _data = data as? [PHAsset] {
                var arrAttachfile:[AttachFileModel] = []
                
                for i in 0..<_data.count{
                    let image:UIImage = self.getAssetThumbnail(asset: _data[i], size: ScreenSize.SCREEN_HEIGHT)
                    if let data = UIImageJPEGRepresentation(image, 0.85) {
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
                    if !self.hasNetworkConnection{
                        if self.orderDetail?.url == nil{
                            self.orderDetail?.url = UrlFileMoldel()
                        }
                        self.orderDetail?.url?.doc?.append(arrAttachfile)
                        CoreDataManager.updateOrderDetail(self.orderDetail!)
                        self.updateOrderDetail?()
                        self.initData()
                        self.upateUI()
                        self.tableView.reloadData()
                    }
                    self.uploadMultipleFile(files: arrAttachfile)
                }
                
            }else if let image = data as? UIImage {
                if let data = UIImageJPEGRepresentation(image, 0.85) {
                    let file: AttachFileModel = AttachFileModel()
                    file.name = "Picture_\(Date().timeIntervalSince1970)"
                    file.type = ".png"
                    file.mimeType = "image/png"
                    file.contentFile = data
                    file.param = "file_pod_req[0]"
                    if !self.hasNetworkConnection{
                        if self.orderDetail?.url == nil{
                            self.orderDetail?.url = UrlFileMoldel()
                        }
                        self.orderDetail?.url?.doc?.append(file)
                        CoreDataManager.updateOrderDetail(self.orderDetail!, { (success, coreRoute) in
                            self.updateOrderDetail?()
                        })
                        self.initData()
                        self.upateUI()
                        self.tableView.reloadData()
                    }
                    self.uploadMultipleFile(files: [file])
                    
                    
                }else {
                    print("encode failure")
                }
            }
        }
    }
    
    @IBAction func clearPhotos(_ sender: UIButton) {
        selectedPictures.removeAll()
        tableView.reloadData()
    }
    
    @IBAction func uploadPhotos(_ sender: UIButton) {
        //
    }
    
    override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Picture".localized)
    }
}

//MARK: API
extension OrderPictureViewController {
    
    private func getOrderDetail() {
        guard let _orderID = orderDetail?.id else { return }
        showLoadingIndicator()
        API().getOrderDetail(orderId: "\(_orderID)") {[weak self] (result) in
            self?.dismissLoadingIndicator()
            
            switch result{
            case .object(let object):
                self?.orderDetail = object
                self?.updateOrderDetail?()
                self?.initData()
                self?.upateUI()
                self?.tableView.reloadData()
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    func uploadImage(_ image:UIImage, title:String) {
        if let data = UIImageJPEGRepresentation(image, 1.0) {
            
            let signatureFile: AttachFileModel = AttachFileModel()
            signatureFile.name = title
            signatureFile.type = ".png"
            signatureFile.mimeType = "image/png"
            signatureFile.contentFile = data
            
            self.upateUI()
            submitPicture(signatureFile)
            
        }else {
            print("encode failure")
        }
    }
    private func submitPicture(_ file: AttachFileModel) {
        guard let order = orderDetail else { return }
        let orderID = String(order.id)
        showLoadingIndicator()
        API().uploadImageToOrder(orderID, file) { [weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                // self?.controlsContainerView.isHidden = true
                self?.showAlertView("Uploaded Successful".localized)
                
                break
            case .error(let error):
                self?.showAlertView(error.getMessage())
                break
                
            }
        }
    }
    
    func uploadMultipleFile(files:[AttachFileModel]){
        guard let order = orderDetail else { return }
        let orderID = String(order.id)
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        API().uploadMultipleImageToOrder(orderID, files) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.getOrderDetail()
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}


extension OrderPictureViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if attachFiles.count > 0 {
            return attachFiles.count
        }
        return selectedPictures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PictureTableViewCell {
            if let _ = orderDetail {
                let picture =  attachFiles[indexPath.row]
                cell.nameLabel.text = picture.name
                if picture.url != nil {
                    cell.imgView.sd_setImage(with: URL(string: E(picture.urlS3)),
                                             placeholderImage: #imageLiteral(resourceName: "place_holder"),
                                             options: .refreshCached, completed: nil)
                }else {
                    cell.imgView.image = UIImage(data: picture.contentFile ?? Data())
                }
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? PictureTableViewCell {
            let picture =  attachFiles[indexPath.row]
            if let _link = picture.url{
                showImage(linkUrl: _link, placeHolder: cell.imgView.image)
            }else{
                showImage(cell.imgView.image, placeHolder: cell.imgView.image)
            }
        }
    }
}


struct PictureObject {
    var name: String
    var image: UIImage
    
    mutating func changeName(_ newName: String)  {
        self.name = newName
    }
}


//MARK: - OtherFuntion
extension OrderPictureViewController{
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

extension PHAsset {
    
    var originalFilename: String? {
        
        var fname:String?
        
        if #available(iOS 9.0, *) {
            let resources = PHAssetResource.assetResources(for: self)
            if let resource = resources.first {
                fname = resource.originalFilename
            }
        }
        
        if fname == nil {
            // this is an undocumented workaround that works as of iOS 9.1
            fname = self.value(forKey: "filename") as? String
        }
        
        return fname
    }
}
