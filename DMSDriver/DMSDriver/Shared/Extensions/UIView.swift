

import UIKit

// MARK: - Designable Extension
@IBDesignable
extension UIView {
    
    @IBInspectable
    /// Should the corner be as circle
    public var circleCorner: Bool {
        get {
            return min(bounds.size.height, bounds.size.width) / 2 == cornerRadius
        }
        set {
            cornerRadius = newValue ? min(bounds.size.height, bounds.size.width) / 2 : cornerRadius
        }
    }
    
    @IBInspectable
    /// Corner radius of view; also inspectable from Storyboard.
    public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = circleCorner ? min(bounds.size.height, bounds.size.width) / 2 : newValue
            //abs(CGFloat(Int(newValue * 100)) / 100)
        }
    }
    
    @IBInspectable
    /// Border color of view; also inspectable from Storyboard.
    public var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }
            layer.borderColor = color.cgColor
        }
    }
    
    @IBInspectable
    /// Border width of view; also inspectable from Storyboard.
    public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    /// Shadow color of view; also inspectable from Storyboard.
    public var shadowColor: UIColor? {
        get {
            guard let color = layer.shadowColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    /// Shadow offset of view; also inspectable from Storyboard.
    public var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    /// Shadow opacity of view; also inspectable from Storyboard.
    public var shadowOpacity: Double {
        get {
            return Double(layer.shadowOpacity)
        }
        set {
            layer.shadowOpacity = Float(newValue)
        }
    }
    
    @IBInspectable
    /// Shadow radius of view; also inspectable from Storyboard.
    public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    /// Shadow path of view; also inspectable from Storyboard.
    public var shadowPath: CGPath? {
        get {
            return layer.shadowPath
        }
        set {
            layer.shadowPath = newValue
        }
    }
    
    @IBInspectable
    /// Should shadow rasterize of view; also inspectable from Storyboard.
    /// cache the rendered shadow so that it doesn't need to be redrawn
    public var shadowShouldRasterize: Bool {
        get {
            return layer.shouldRasterize
        }
        set {
            layer.shouldRasterize = newValue
        }
    }
    
    @IBInspectable
    /// Should shadow rasterize of view; also inspectable from Storyboard.
    /// cache the rendered shadow so that it doesn't need to be redrawn
    public var shadowRasterizationScale: CGFloat {
        get {
            return layer.rasterizationScale
        }
        set {
            layer.rasterizationScale = newValue
        }
    }
    
    @IBInspectable
    /// Corner radius of view; also inspectable from Storyboard.
    public var maskToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
}

// MARK: - Properties

public extension UIView {
    
    /// Size of view.
    public var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.width = newValue.width
            self.height = newValue.height
        }
    }
    
    /// Width of view.
    public var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    /// Height of view.
    public var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
}

extension UIView {
    
    func removeAllConstraints() {
        removeConstraints(self.constraints);
    }
    
    func removeAllConstraintsIncludesSubviews() {
        removeAllConstraints();
        
        for subView in self.subviews {
            subView.removeAllConstraintsIncludesSubviews();
        }
        
    }
    
    func addConstaints(top: CGFloat? = nil,
                       right: CGFloat? = nil,
                       bottom: CGFloat? = nil,
                       left: CGFloat? = nil,
                       width: CGFloat? = nil,
                       height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if top != nil { self.addConstaint(top: top!) }
        if right != nil { self.addConstaint(right: right!) }
        if bottom != nil { self.addConstaint(bottom: bottom!) }
        if left != nil { self.addConstaint(left: left!) }
        if width != nil { self.addConstaint(width: width!) }
        if height != nil { self.addConstaint(heigh: height!) }
        
    }
    
    func addConstaint(top offset: CGFloat) {
        guard superview != nil else { return }
        topAnchor.constraint(equalTo: superview!.topAnchor, constant: offset).isActive = true
    }
    
    func addConstaint(right offset: CGFloat) {
        guard superview != nil else { return }
        rightAnchor.constraint(equalTo: superview!.rightAnchor, constant: offset).isActive = true
    }
    
    func addConstaint(left offset: CGFloat) {
        guard superview != nil else { return }
        leftAnchor.constraint(equalTo: superview!.leftAnchor, constant: offset).isActive = true
    }
    
    func addConstaint(bottom offset: CGFloat) {
        guard superview != nil else { return }
        bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: offset).isActive = true
    }
    
    func addConstaint(width offset: CGFloat) {
        guard superview != nil else { return }
        widthAnchor.constraint(equalTo: superview!.widthAnchor, constant: offset).isActive = true
    }
    func addConstaint(heigh offset: CGFloat) {
        guard superview != nil else { return }
        heightAnchor.constraint(equalTo: superview!.heightAnchor, constant: offset).isActive = true
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
