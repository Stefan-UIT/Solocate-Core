//
//  SignatureView.swift
//  SRSDriver
//
//  Created by phunguyen on 3/16/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

protocol SignatureViewDelegate:class {
    func touchesMoved(_ sign: UIBezierPath?,_ signLayer:CAShapeLayer?)
}

class SignatureView: UIView {
    
 weak var delegate:SignatureViewDelegate?

  private var beginLocation: CGPoint! {
    didSet {
      sign = UIBezierPath()
      sign?.move(to: beginLocation)
      signLayer = CAShapeLayer()
      signLayer?.path = sign?.cgPath
      signLayer?.lineWidth = 2.0
      signLayer?.lineJoin = kCALineJoinRound
      signLayer?.fillColor = UIColor.clear.cgColor
      signLayer?.strokeColor = UIColor.black.cgColor
      if let _signLayer = signLayer {
        self.layer.addSublayer(_signLayer)
      }
    }
  }
  
  var signLayer: CAShapeLayer?
  private var endingLocation: CGPoint! {
    didSet {
      sign?.addLine(to: endingLocation)
      signLayer?.path = sign?.cgPath
    }
  }
  var sign: UIBezierPath?

  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      let location = touch.location(in: self)
      guard self.frame.contains(location), sign != nil else {
        return
      }
      sign?.addLine(to: CGPoint(x: location.x, y: location.y - self.frame.origin.y))
      signLayer?.path = sign?.cgPath
        
      delegate?.touchesMoved(sign, signLayer)
    }
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      let location = touch.location(in: self)
      guard self.frame.contains(location) else {
        return
      }
      beginLocation = CGPoint(x: location.x, y: location.y - self.frame.origin.y)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      let location = touch.location(in: self)
      guard self.frame.contains(location) else {
        return
      }
      endingLocation = CGPoint(x: location.x, y: location.y - self.frame.origin.y)
    }
  }

}
