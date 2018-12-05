//
//  OrderSignatureViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class OrderSignatureViewController: BaseOrderDetailViewController {
    @IBOutlet weak var controlsContainerView: UIStackView?
  
    @IBOutlet weak var signatureView: SignatureView?
    @IBOutlet weak var signatureImgView: UIImageView?
    @IBOutlet weak var btnSubmit: UIButton?
    @IBOutlet weak var btnClear: UIButton?
        
    var validationSubmit:Bool = false{
        didSet{
            controlsContainerView?.alpha = validationSubmit ? 1 : 0.4
            controlsContainerView?.isUserInteractionEnabled = validationSubmit
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        validationSubmit = false
        signatureView?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func reachabilityChangedNotification(_ notification: NSNotification) {
        super.reachabilityChangedNotification(notification)
        /*
        if hasNetworkConnection {
            updateOrderDetail?(orderDetail)
        }else {
            CoreDataManager.queryOrderDetail(orderDetail?.id ?? 0, callback:{[weak self] (success, data) in
                self?.orderDetail = data
                self?.updateUI()

            })
        }
         */
    }
  
    override func updateUI() {
        super.updateUI()
        DispatchQueue.main.async { [weak self] in
            self?.setupButtonAction()
            self?.setupSignatureView()
        }
    }
  
  
    override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Signature".localized)
    }
  
    @IBAction func cancelDrawSignature(_ sender: UIButton) {
        validationSubmit = false
        signatureView?.sign?.removeAllPoints()
        signatureView?.signLayer?.path = nil
        signatureView?.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
    }
  
    @IBAction func submitSignature(_ sender: UIButton) {
        let rect = signatureView?.frame ?? CGRect.zero
        guard signatureView?.signLayer != nil else {
            return
        }
    
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        signatureView?.layer.render(in: context)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = img, let data = UIImageJPEGRepresentation(image, 1.0) {
            let signatureFile: AttachFileModel = AttachFileModel()
            signatureFile.name = "Signature_\(orderDetail?.id ?? 0)"
            signatureFile.type = ".png"
            signatureFile.mimeType = "image/png"
            signatureFile.contentFile = data
            signatureFile.param = "file_sig_req"
            
            if orderDetail?.url == nil {
                orderDetail?.url = UrlFileMoldel()
            }
            orderDetail?.url?.sig = signatureFile
            
            if !hasNetworkConnection{
                CoreDataManager.updateOrderDetail(orderDetail!) { (success, data) in
                    self.updateOrderDetail?(self.orderDetail)
                }
                
                updateUI()
            }
            
            submitSignature(signatureFile)
            
        }else {
            print("encode failure")
        }
    }
    
    func setupButtonAction()  {
        btnClear?.setTitle("Clear".localized.uppercased(), for: .normal)
        btnSubmit?.setTitle("Submit".localized.uppercased(), for: .normal)
    }
  
    func setupSignatureView()  {
        guard let order = self.orderDetail else { return }
        guard let signFile:AttachFileModel = order.url?.sig else {
            self.controlsContainerView?.isHidden = false
            self.signatureImgView?.isHidden = true
            return
        }
        
        self.controlsContainerView?.isHidden = true
        self.signatureImgView?.isHidden = false
        
        if (self.hasNetworkConnection) == false {
            self.signatureImgView?.image = UIImage(data: signFile.contentFile ?? Data())
            return
        }
        
        self.signatureImgView?.sd_setImage(with: URL(string: E(signFile.url)),
                                            placeholderImage: nil,
                                            options: .allowInvalidSSLCertificates,
                                            completed: { (image, error, cacheType, url) in
            if error == nil{
                if let image = image,
                    let data = UIImageJPEGRepresentation(image, 1.0) {
                    signFile.contentFile = data
                    CoreDataManager.updateOrderDetail(order)
                }
            }
        })
    }
    
    private func submitSignature(_ file: AttachFileModel) {
        guard let order = orderDetail else { return }
        if hasNetworkConnection {
            showLoadingIndicator()
        }
        API().submitSignature(file,order) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.controlsContainerView?.isHidden = true
                self?.signatureView?.isUserInteractionEnabled = false
                self?.updateOrderDetail?(self?.orderDetail)
                self?.showAlertView("Uploaded Successful".localized)

            case .error(let error):
                self?.showAlertView(error.getMessage())
                break
            }
        }
    }
}


class BaseOrderDetailViewController: BaseViewController, IndicatorInfoProvider {
    var orderDetail: Order?
    var route: Route?
    var rootVC:OrderDetailContainerViewController?
    var indicatorInfo = IndicatorInfo(title: "")

    var checkConnetionInternet:((_ notification:NSNotification, _ hasConnectionInternet: Bool) -> Void)?
    var didUpdateStatus:((_ orderDetail:Order, _ shouldMoveToTab: Int?) -> Void)?
    var updateOrderDetail:((_ order:Order?) -> Void)?

    convenience init(_ title: String) {
        self.init()
        indicatorInfo = IndicatorInfo(title: title)
    }

    func setTitle(_ title: String) {
        indicatorInfo = IndicatorInfo(title: title)
    }


    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return indicatorInfo
    }
}


//MARK: - SignatureViewDelegate
extension OrderSignatureViewController:SignatureViewDelegate{
    func touchesMoved(_ sign: UIBezierPath?, _ signLayer: CAShapeLayer?) {
        self.validationSubmit = (sign != nil)
    }
}
