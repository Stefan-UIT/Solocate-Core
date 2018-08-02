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
    @IBOutlet weak var controlsContainerView: UIStackView!
  
    @IBOutlet weak var signatureView: SignatureView!
    @IBOutlet weak var signatureImgView: UIImageView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var unableToFinishButton: UIButton!
    
    var updateOrderDetail:(() -> Void)?
    
    var validationSubmit:Bool = false{
        didSet{
            controlsContainerView.alpha = validationSubmit ? 1 : 0.4
            controlsContainerView.isUserInteractionEnabled = validationSubmit

        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        validationSubmit = false
        signatureView.delegate = self
        updateUI()
    }
    
    override var orderDetail: OrderDetail?{
        didSet{
            updateUI()
        }
    }
  
    func updateUI() {
        guard let order = orderDetail else { return }
    
        if let signFile:AttachFileModel = order.url?.sig{
            controlsContainerView.isHidden = true
            signatureImgView.isHidden = false
        
            signatureImgView.sd_setImage(with: URL(string: E(signFile.url)),
                                     placeholderImage: nil,
                                     options: .allowInvalidSSLCertificates,
                                     completed: nil)
      
        }else {
            controlsContainerView.isHidden = false
            signatureImgView.isHidden = true
        }
    }
  
  
    override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Signature".localized)
    }
  
    @IBAction func cancelDrawSignature(_ sender: UIButton) {
        validationSubmit = false
        signatureView.sign?.removeAllPoints()
        signatureView.signLayer?.path = nil
        signatureView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
    }
  
    @IBAction func submitSignature(_ sender: UIButton) {
        let rect = signatureView.frame
        guard signatureView.signLayer != nil else {
            return
        }
    
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return}
        signatureView.layer.render(in: context)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = img, let data = UIImageJPEGRepresentation(image, 1.0) {
        let signatureFile: AttachFileModel = AttachFileModel()
        signatureFile.name = "Signature_\(orderDetail?.id ?? 0)"
        signatureFile.type = ".png"
        signatureFile.mimeType = "image/png"
        signatureFile.contentFile = data
      
        submitSignature(signatureFile)
      
        }else {
            print("encode failure")
        }
  }
  
    private func submitSignature(_ file: AttachFileModel) {
        guard let order = orderDetail else { return }
        showLoadingIndicator()
        API().submitSignature(file, "\(order.id)") {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(_):
                self?.controlsContainerView.isHidden = true
                self?.signatureView.isUserInteractionEnabled = false
                self?.updateOrderDetail?()
                self?.showAlertView("Uploaded Successful".localized)

                break
            case .error(let error):
                self?.showAlertView(error.getMessage())
                break
        
            }
        }
    }
}


class BaseOrderDetailViewController: BaseViewController, IndicatorInfoProvider {
  var orderDetail: OrderDetail?
  var routeID: Int?
  var indicatorInfo = IndicatorInfo(title: "")
  
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
