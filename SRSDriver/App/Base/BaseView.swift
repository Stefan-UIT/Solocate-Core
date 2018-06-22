//
//  BaseView.swift
//  DMSDriver
//
//  Created by MrJ on 4/17/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class BaseView: UIView {
    var keyboardHeight : CGFloat = 0.0
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func config() {
        _ = instanceFromNib()
    }
    
    func addObserverKeyboardWillShow() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) -> CGFloat {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.keyboardHeight = keyboardHeight
            return keyboardHeight
        }
        return 0.0
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        if let _: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            self.keyboardHeight = 0.0
        }
    }
    
    func showViewInView(superView : UIView, isHiddenStatusBar:Bool? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow
        statusBarWindow?.alpha = 0.0
        
        if let isHiddenStatusBar = isHiddenStatusBar {
            if isHiddenStatusBar == false {
                statusBarWindow?.alpha = 1.0
            }
        }
        superView.addSubview(self)
        
        // align self from the left and right
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self]));
        
        // align self from the top and bottom
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self]));
        
        self.layoutIfNeeded()
        self.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1.0
        }
    }
    
    func showViewInWindow() {
        if let delegate = UIApplication.shared.delegate {
            if let _window = delegate.window as? UIWindow{
                showViewInView(superView: _window)
            }
        }
    }
    
    func showViewInTopWindow() {
        if let delegate = UIApplication.shared.delegate {
            if let _window = delegate.window as? UIWindow{
                showViewInTop(superView: _window)
            }
        }
    }
    
    func showViewInTop(superView : UIView) {
        let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow
        statusBarWindow?.alpha = 0.0
        self.translatesAutoresizingMaskIntoConstraints = false
        
        superView.addSubview(self)
        
        // align view from the left and right
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self]));
        
        // align view from the top
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self]));
    }
    
    override func removeFromSuperview() {
        let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow
        statusBarWindow?.alpha = 1.0
        super.removeFromSuperview()
    }
}
extension BaseView {
    
    func instanceFromNib<T : UIView>() -> T? {
        print("\nView ---\(NSStringFromClass(type(of: self)))---\n")
        guard let view = UINib(nibName: String(describing: type(of: self)), bundle: nil).instantiate(withOwner: self, options: nil).first as? T else {
            return nil
        }
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutAttachAll(to: self)
        return view
    }
}

extension UIView {
    func layoutAttachAll(to view: UIView) {
        // align self from the left and right
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self]));
        
        // align self from the top and bottom
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self]));    }
}
