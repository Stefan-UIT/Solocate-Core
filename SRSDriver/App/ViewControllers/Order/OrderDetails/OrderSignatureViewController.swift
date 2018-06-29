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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupSignatureView()
    guard let order = orderDetail else { return }
    controlsContainerView.isHidden = order.sign.length > 0
    signatureView.isHidden = order.sign.length > 0
    signatureImgView.isHidden = !(order.sign.length > 0)
    
    guard order.sign.length > 0 else {
      return
    }
    let baseURL = order.sign
    let data = Data(base64Encoded: baseURL, options: .ignoreUnknownCharacters)
    signatureImgView.image = UIImage(data: data ?? Data())
  }
    
    func setupSignatureView() {
        signatureView.cornerRadius = 5.0;
        signatureView.borderColor = UIColor.lightGray
        signatureView.borderWidth = 1.0;
    }
  
  
  override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: "order_detail_signature".localized)
  }
  
  @IBAction func cancelDrawSignature(_ sender: UIButton) {
    signatureView.sign.removeAllPoints()
    signatureView.signLayer.path = nil
    signatureView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
  }    
  
  @IBAction func submitSignature(_ sender: UIButton) {
    let rect = signatureView.frame
    guard signatureView.signLayer != nil else {
      return
    }
    
    UIGraphicsBeginImageContext(rect.size)
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    signatureView.layer.render(in: context)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    if let image = img, let data = UIImageJPEGRepresentation(image, 1.0) {
      let dataBase = data.base64EncodedString(options: .lineLength64Characters)
      // submit data
      submitSignature(dataBase)
    }
    else {
      print("encode failure")
    }
  }
  
  private func submitSignature(_ baseString: String) {
    guard let order = orderDetail else { return }
    showLoadingIndicator()
    APIs.uploadSignature("\(order.id)", signBase64: baseString) { [weak self] (errorMsg) in
      self?.dismissLoadingIndicator()
      guard let msg = errorMsg else {
        self?.controlsContainerView.isHidden = true
        self?.showAlertView("order_detail_add_signature_successfully".localized, completionHandler: { (action) in
          self?.navigationController?.popViewController(animated: true)
        })
        return
      }
      self?.showAlertView(msg)
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
