

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
            layer.cornerRadius = newValue
            layer.masksToBounds = true
            clipsToBounds = true
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
    
    func roundedCorners(_ corners: CACornerMask, _ radius: CGFloat) {
        if #available(iOS 11.0, *) {
            self.clipsToBounds = true
            self.layer.masksToBounds = true
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = corners
        } else {
            // Fallback on earlier versions
        }
    }
    
    func roundCornersLRT() {
        self.roundedCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], 10)
        self.addBorders(edges: [.left, .right, .top], color: AppColor.grayBorderColor, width: 0.5)
    }
    
    func noRoundCornersLRT() {
        self.roundedCorners([.layerMaxXMinYCorner,
                             .layerMinXMinYCorner,
                             .layerMaxXMaxYCorner,
                             .layerMinXMaxYCorner], 0)
        self.addBorders(edges: [.left, .right], color: AppColor.white, width: 0.5)
    }
    
    func roundCornersLRB(colorBorder:UIColor? = nil, widthBorder:CGFloat? = nil) {
        self.roundedCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner], 10)
        self.addBorders(edges: [.left, .right, .bottom],
                        color: (colorBorder != nil) ? colorBorder! : AppColor.white,
                        width: (widthBorder != nil) ? widthBorder! : 0.5)
    }
    
    
    func roundCornersEdgesAll()  {
        self.roundedCorners([.layerMaxXMinYCorner,
                             .layerMinXMinYCorner,
                             .layerMaxXMaxYCorner,
                             .layerMinXMaxYCorner],
                            5)
        self.addBorders(edges: [.all], color: AppColor.white, width: 0.5)
    }
    
    func addBorders(edges: UIRectEdge = .all, color: UIColor = .black, width: CGFloat = 1.0) {
        
        func createBorder() -> UIView {
            let borderView = UIView(frame: CGRect.zero)
            borderView.translatesAutoresizingMaskIntoConstraints = false
            borderView.backgroundColor = color
            borderView.maskToBounds = true
            borderView.clipsToBounds = true
            return borderView
        }
        
        if (edges.contains(.all) || edges.contains(.top)) {
            let topBorder = createBorder()
            self.addSubview(topBorder)
            NSLayoutConstraint.activate([
                topBorder.topAnchor.constraint(equalTo: self.topAnchor),
                topBorder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                topBorder.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                topBorder.heightAnchor.constraint(equalToConstant: width)
                ])
        }
        if (edges.contains(.all) || edges.contains(.left)) {
            let leftBorder = createBorder()
            self.addSubview(leftBorder)
            NSLayoutConstraint.activate([
                leftBorder.topAnchor.constraint(equalTo: self.topAnchor),
                leftBorder.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                leftBorder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                leftBorder.widthAnchor.constraint(equalToConstant: width)
                ])
        }
        if (edges.contains(.all) || edges.contains(.right)) {
            let rightBorder = createBorder()
            self.addSubview(rightBorder)
            NSLayoutConstraint.activate([
                rightBorder.topAnchor.constraint(equalTo: self.topAnchor),
                rightBorder.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                rightBorder.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                rightBorder.widthAnchor.constraint(equalToConstant: width)
                ])
        }
        if (edges.contains(.all) || edges.contains(.bottom)) {
            let bottomBorder = createBorder()
            self.addSubview(bottomBorder)
            NSLayoutConstraint.activate([
                bottomBorder.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                bottomBorder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                bottomBorder.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                bottomBorder.heightAnchor.constraint(equalToConstant: width)
                ])
        }
    }
    
    func styleShadowTop() {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 2)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
    
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
    
    class func load<T: UIView>(nib: String? = nil, owner: Any? = nil) -> T {
        return Bundle.main.loadNibNamed(_:nib != nil ? nib! : String(describing: T.self),
                                        owner: owner,
                                        options: nil)?.first as! T;
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
    
    public func setShadowDefault() {
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.1, height: 5.0)
        self.layer.shadowOpacity = 0.2
    }
}

extension UIView {
    
    @discardableResult
    class func addViewNoItemWithTitle(_ title:String,intoParentView parentView:UIView) -> UIView{
        removeViewNoItemAtParentView(parentView)
        
        let view = UIView(frame: CGRectMake(0, 0, parentView.frame.size.width/2, 70))
        view.isUserInteractionEnabled = false
        let imv = UIImageView(frame: CGRectMake(0, 5, view.frame.size.width, 25))
        imv.image = UIImage(named: "ic-NoImageGray")
        imv.contentMode = .scaleAspectFit
        view.addSubview(imv)
        
        let lbl = UILabel(frame: CGRectMake(0, 45, view.frame.size.width, 20))
        lbl.text = title
        lbl.textAlignment = .center
        lbl.textColor = AppColor.grayBorderColor
        view.addSubview(lbl)
        view.center = parentView.center
        view.tag = 1000
        
        parentView.addSubview(view)
        
        return view
    }
    
    
    class func removeViewNoItemAtParentView(_ parentView:UIView)  {
        let view = parentView.viewWithTag(1000)
        view?.removeFromSuperview()
    }
    
    func addSubview(_ subView: UIView, edge: UIEdgeInsets) {
        let frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        let margin = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let content = frame.inset(by: margin)
        subView.frame = content
        addSubview(subView);
    }
    
}


extension CGFloat {
    func scaleHeight() -> CGFloat {
        return self*Constants.SCALE_VALUE_HEIGHT_DEVICE
    }
}
