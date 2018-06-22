

import UIKit

extension UIView {
  
  @IBInspectable var cornerRadius: CGFloat {
    
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
      layer.masksToBounds = newValue > 0
    }
  }
  
  @IBInspectable var borderWidth: CGFloat {
    
    get {
      return layer.borderWidth
    }
    
    set {
      
      layer.borderWidth = newValue
    }
  }
  
  @IBInspectable var borderColor: UIColor? {
    
    get {
      return UIColor(cgColor: layer.borderColor!)
    }
    
    set {
      
      layer.borderColor = newValue?.cgColor
    }
  }
  
  class func loadNib<T: UIView>(viewType: T.Type) -> T {
    let className = String.className(aClass: viewType)
    return Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as! T
  }
  
  class func loadNib() -> Self {
    return loadNib()
  }
  
  var parentViewController: UIViewController? {
    var parentResponder: UIResponder? = self
    while parentResponder != nil {
      parentResponder = parentResponder!.next
      if let viewController = parentResponder as? UIViewController {
        return viewController
      }
    }
    return nil
  }
  
  func applyGradient(colours: [UIColor]) -> Void {
    self.applyGradient(colours: colours, locations: nil)
  }
  
  func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
    let gradient: CAGradientLayer = CAGradientLayer()
    gradient.frame = self.bounds
    gradient.colors = colours.map { $0.cgColor }
    gradient.locations = locations
    self.layer.insertSublayer(gradient, at: 0)
  }
}

extension CGFloat {
  func scaleHeight() -> CGFloat {
    return self*Constants.SCALE_VALUE_HEIGHT_DEVICE
  }
}
