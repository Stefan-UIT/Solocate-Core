//
//  ApprovePictureViewController.swift
//  SRSDriver
//
//  Created by MrJ on 2/12/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit

typealias ApprovePictureViewControllerCallback = (Bool,Order?) -> Void
class ApprovePictureViewController: BaseViewController {

    // MARK: IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: Variables
    var imageToApprove: UIImage?
    var navigationService = DMSNavigationService()
    var callback:ApprovePictureViewControllerCallback?
    var order:Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = imageToApprove
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        App().statusBarView?.backgroundColor = AppColor.white
    }

    override func updateNavigationBar() {
        super.updateNavigationBar()
        App().statusBarView?.backgroundColor = AppColor.background
        navigationService.navigationItem = self.navigationItem
        navigationService.navigationBar = self.navigationController?.navigationBar
        navigationService.delegate = self
        navigationService.updateNavigationBar(.Menu,"",AppColor.background)
    }
    
    // MARK: Action
    @IBAction func retryButtonAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func okButtonAction(_ sender: UIButton) {
        if let data = imageToApprove?.jpegData(compressionQuality: 0.75) {
            let file: AttachFileModel = AttachFileModel()
            file.name = "Picture_\(Date().timeIntervalSince1970)"
            file.type = ".png"
            file.typeFile = "SIG"
            file.mimeType = "image/png"
            file.contentFile = data
            file.param = "file_pod_req[0]"

            if order?.isRequireSign() == false {
                uploadMultipleFile(files: [file], isNeedFinishOrder: true)
                
            }else {
                uploadMultipleFile(files: [file], isNeedFinishOrder: false)
            }

        }else {
            print("encode failure")
        }
    }
}


//MARK: - DMSNavigationServiceDelegate
extension ApprovePictureViewController:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        showSideMenu()
    }
}

//MARK: - API
extension ApprovePictureViewController{
    fileprivate func uploadMultipleFile(files:[AttachFileModel], isNeedFinishOrder:Bool = false){
        guard let orderCopy:Order = order?.cloneObject() else {
            return
        }
        if isNeedFinishOrder {
            let listStatus =  CoreDataManager.getListStatus()
            for item in listStatus {
                if item.code == StatusOrder.deliveryStatus.rawValue{
                    orderCopy.status = item
                    break
                }
            }
        }
       
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        SERVICES().API.uploadMultipleImageToOrder(files, orderCopy) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                if isNeedFinishOrder {
                    self?.showAlertView("Order:#\(orderCopy.id) has delevered successfully.".localized) {[weak self](action) in
                        if orderCopy.files == nil{
                            orderCopy.files = []
                        }
                        orderCopy.files?.append(files)
                        self?.callback?(true,orderCopy)
                        self?.dismiss(animated: true, completion: nil)
                        App().mainVC?.rootNV?.popToController(OrderDetailViewController.self, animated: true)
                    }
               
                }else {
                    self?.showSignatureViewController()
                }
     
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    fileprivate func updateStatusOrder(statusCode: String) {
        guard let _orderDetail = order else {
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
        
        SERVICES().API.updateOrderStatus(_orderDetail) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.callback?(true,_orderDetail)
                self?.dismiss(animated: true, completion: nil)
                App().mainVC?.rootNV?.popToController(OrderDetailViewController.self, animated: true)
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    
    fileprivate func submitSignature(file: AttachFileModel, isNeedFinishOrder:Bool = false, name:String)  {
        guard let orderCopy:Order = order?.cloneObject() else {
            return
        }
        if isNeedFinishOrder {
            let listStatus =  CoreDataManager.getListStatus()
            for item in listStatus {
                if item.code == StatusOrder.deliveryStatus.rawValue{
                    orderCopy.status = item
                    break
                }
            }
        }
       
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        SERVICES().API.submitSignature(file,orderCopy,name) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                if isNeedFinishOrder  == false{
                    return
                }
                self?.showAlertView("Order:#\(orderCopy.id) has delevered successfully.".localized) {[weak self](action) in
                    if orderCopy.files == nil{
                        orderCopy.files = []
                    }
                    orderCopy.files?.append(file)
                    self?.callback?(true,orderCopy)
                    self?.dismiss(animated: true, completion: nil)
                    App().mainVC?.rootNV?.popToController(OrderDetailViewController.self, animated: true)
                }
                
            case .error(let error):
                self?.showAlertView(error.getMessage())
                break
            }
        }
    }
}


//MARK: - Other funtion
extension ApprovePictureViewController{
   fileprivate func showSignatureViewController()  {
        let viewController = SignatureViewController()
        viewController.order = order
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
   fileprivate func handleFinishOrShowSignatureViewcontroller() {
        if order?.isRequireSign() ?? false {
            showSignatureViewController()
        }else {
            updateStatusOrder(statusCode: StatusOrder.deliveryStatus.rawValue)
        }
    }
}

//MARK: - SignatureViewControllerDelegate
extension ApprovePictureViewController:SignatureViewControllerDelegate {
    func signatureViewController(view: SignatureViewController, didCompletedSignature signature: AttachFileModel?, signName:String?) {
        if let sig  = signature {
            submitSignature(file: sig, isNeedFinishOrder: true, name: signName ?? "" )
        }
    }
}
