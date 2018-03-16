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
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
  
  
  override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: "Signature")
  }
  
  @IBAction func cancelDrawSignature(_ sender: UIButton) {
    signatureView.sign.removeAllPoints()
    signatureView.signLayer.path = nil
  }
  
  @IBAction func submitSignature(_ sender: UIButton) {
    let rect = signatureView.frame
    guard signatureView.signLayer != nil else {
      print("null")
      return
    }
    
    UIGraphicsBeginImageContext(rect.size)
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    signatureView.layer.render(in: context)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    if let image = img, let data = UIImageJPEGRepresentation(image, 0.8) {
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
    APIs.uploadSignature("\(order.id)", signBase64: baseString) { (errorMsg) in
      self.dismissLoadingIndicator()
      guard let msg = errorMsg else {
        self.controlsContainerView.isHidden = true
        return
      }
      self.showAlertView(msg)
    }
  }
  
  
  
  
  
}


class BaseOrderDetailViewController: BaseViewController, IndicatorInfoProvider {
  var orderDetail: OrderDetail?
  var indicatorInfo = IndicatorInfo(title: "Detail")
  
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
