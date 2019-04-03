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

    override func updateNavigationBar() {
        super.updateNavigationBar()
        App().statusBarView?.backgroundColor = AppColor.background
        navigationService.navigationItem = self.navigationItem
        navigationService.navigationBar = self.navigationController?.navigationBar
        navigationService.delegate = self
        navigationService.updateNavigationBar(.Menu,nil,AppColor.background)
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
            file.mimeType = "image/png"
            file.contentFile = data
            file.param = "file_pod_req[0]"

            uploadMultipleFile(files: [file])

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
    fileprivate func uploadMultipleFile(files:[AttachFileModel]){
        guard let order = order else { return }
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        SERVICES().API.uploadMultipleImageToOrder(files, order) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.handleFinishOrShowSignatureViewcontroller()
     
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
    
   fileprivate func submitSignature(_ file: AttachFileModel) {
        guard let order = order else { return }
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        SERVICES().API.submitSignature(file,order) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.updateStatusOrder(statusCode: StatusOrder.deliveryStatus.rawValue)
                
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
    func signatureViewController(view: SignatureViewController, didCompletedSignature signature: AttachFileModel) {
        submitSignature(signature)
    }
}
