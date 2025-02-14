
import UIKit
import Foundation

/// Common Navigation bar Styles.
extension UINavigationBar {
    //
}

/// Common navigation methods used by UIViewController.
extension UIViewController {
    func addTitleToNavigationBar(title: String, color:UIColor? = AppColor.white) {
       let label = UILabel()
        
        label.textColor = color
        //label.font = Font.helveticaRegular(with: 17)
        label.text = title
        label.sizeToFit()
        
        navigationItem.titleView = label
    }
}

/// Common navigation methods used by UIViewController.
extension UINavigationController {
    func addTitleToNavigationBarItem(title: String, color:UIColor? = AppColor.black) {
        let label = UILabel()
        
        label.textColor = color
        //label.font = Font.helveticaRegular(with: 17)
        label.text = title
        label.sizeToFit()
        
        self.navigationItem.titleView = label
    }
}


/// Common UIBarButtonItems used in the app.
extension UIBarButtonItem {
    class func back(target: Any, action: Selector) -> UIBarButtonItem {
        let frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let insets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 8)
        let button = customButton(with: #imageLiteral(resourceName: "ic_Back"),
                                  highlightedImage: #imageLiteral(resourceName: "ic_Back"),
                                  frame: frame,
                                  imageEdgeInsets: insets,
                                  target: target,
                                  action: action)
        button.imageView?.contentMode = .scaleAspectFit
        let item = UIBarButtonItem(customView: button)

        return item
    }

    class func close(target: Any, action: Selector) -> UIBarButtonItem {
        let frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let insets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 0)
        let button = customButton(with: #imageLiteral(resourceName: "ic-Close"),
                                  highlightedImage: #imageLiteral(resourceName: "ic-Close"),
                                  frame: frame,
                                  imageEdgeInsets: insets,
                                  target: target,
                                  action: action)

        let item = UIBarButtonItem(customView: button)

        return item
    }
    
    class func compact(target: Any, action: Selector) -> UIBarButtonItem {
        let frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let insets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 0)
        let button = customButton(with: #imageLiteral(resourceName: "ic_compact_white"),
                                  highlightedImage: #imageLiteral(resourceName: "ic_compact_white"),
                                  frame: frame,
                                  imageEdgeInsets: insets,
                                  target: target,
                                  action: action)
        
        let item = UIBarButtonItem(customView: button)
        
        return item
    }
    
    class func module(target: Any, action: Selector) -> UIBarButtonItem {
        let frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let insets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 0)
        let button = customButton(with: #imageLiteral(resourceName: "ic_module_white"),
                                  highlightedImage: #imageLiteral(resourceName: "ic_module_white"),
                                  frame: frame,
                                  imageEdgeInsets: insets,
                                  target: target,
                                  action: action)
        
        let item = UIBarButtonItem(customView: button)
        
        return item
    }

    class func menu(target: Any, action: Selector) -> UIBarButtonItem {
        let frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let button = customButton(with: #imageLiteral(resourceName: "ellipsis-v-regular"),
                                  frame: frame,
                                  target: target,
                                  action: action)

        let item = UIBarButtonItem(customView: button)

        return item
    }
    
    class func attachedFiles(target: Any, action: Selector) -> UIBarButtonItem {
        let frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let image = UIImage(named: "ic_attachment")
        let button = customButton(with: image!,
                                  frame: frame,
                                  target: target,
                                  action: action)
        
        let item = UIBarButtonItem(customView: button)
        
        return item
    }
    
    class func barButtonItem(with image:UIImage, imageType:ImageType? = nil, target: Any, action: Selector) -> UIBarButtonItem {
        let frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let button = customButton(with: image,
                                  imageType: imageType,
                                  frame: frame,
                                  target: target,
                                  action: action)
        
        let item = UIBarButtonItem(customView: button)
        
        return item
    }
    
    class func filterButton(target: Any, action: Selector) -> UIBarButtonItem {
        let button = filterButtonWithText(text: "filter".localized, target: target, action: action)
        let item = UIBarButtonItem(customView: button)
        
        return item
    }
    
    class func cancelButton(target: Any, action: Selector) -> UIBarButtonItem {
        let button = setUpButtonWithText(text: "cancel".localized, target: target, action: action)
        let item = UIBarButtonItem(customView: button)
        
        return item
    }

    class func doneButton(target: Any, action: Selector) -> UIBarButtonItem {
        let button = setUpButtonWithText(text: "done".localized, target: target, action: action)
        let item = UIBarButtonItem(customView: button)
        
        return item
    }
    
    class func selectButton(target: Any, action: Selector) -> UIBarButtonItem {
        let button = setUpButtonWithText(text: "Select".localized, target: target, action: action)
        let item = UIBarButtonItem(customView: button)
        
        return item
    }
    
    class func assignButton(target: Any, action: Selector) -> UIBarButtonItem {
        let button = setUpButtonWithText(text: "Assign".localized, target: target, action: action)
        let item = UIBarButtonItem(customView: button)
        
        return item
    }
    
    class func SaveButton(target: Any, action: Selector) -> UIBarButtonItem {
        let button = setUpButtonWithText(text: "Save".localized, target: target, action: action)
        let item = UIBarButtonItem(customView: button)
        
        return item
    }
    
    fileprivate class func filterButtonWithText(text:String, target:Any,action: Selector) -> UIButton{
        let title = text
        let font = Font.helveticaRegular(with: 16)

        let frame = CGRect(origin: CGPoint(), size: CGSize(width: 70, height: 20))
        
        
        let normalTitle = NSAttributedString.attributedString(with: title,
                                                              color: AppColor.pickedUpStatus,
                                                              font: font,
                                                              alignment: .right)
        let highlightedTitle = NSAttributedString.attributedString(with: title,
                                                                   color: AppColor.pickedUpStatus,
                                                                   font: font,
                                                                   alignment: .right)
        
        let button = customButton(with: normalTitle,
                                  highlightedTitle: highlightedTitle,
                                  frame: frame,
                                  target: target,
                                  action: action)
        button.borderWidth = 2.0
        button.borderColor = AppColor.pickedUpStatus
        
        return button;
    }
    
    
    fileprivate class func setUpButtonWithText(text:String, target:Any,action: Selector) -> UIButton{
        let title = text
        let font = Font.helveticaRegular(with: 14)
        
        let labelSize = title.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 15),
                                           options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                           attributes: [NSAttributedString.Key.font: font],
                                           context: nil).size
        let frame = CGRect(origin: CGPoint(), size: labelSize)
        
        
        let normalTitle = NSAttributedString.attributedString(with: title,
                                                              color: AppColor.white,
                                                              font: font,
                                                              alignment: .right)
        let highlightedTitle = NSAttributedString.attributedString(with: title,
                                                                   color: AppColor.white,
                                                                   font: font,
                                                                   alignment: .right)
        
        let button = customButton(with: normalTitle,
                                  highlightedTitle: highlightedTitle,
                                  frame: frame,
                                  target: target,
                                  action: action)
        return button;
    }

    fileprivate class func customButton(with image: UIImage,
                                        imageType:ImageType? = nil,
                                        highlightedImage: UIImage? = nil,
                                        frame: CGRect,
                                        imageEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero,
                                        target: Any,
                                        action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        if let _imageType = imageType, _imageType == .Button {
            button.imageView?.tintColor = AppColor.mainColor
        }
        button.setImage(image, for: .normal)
        button.setImage(highlightedImage, for: .highlighted)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.frame = frame
        button.imageEdgeInsets = imageEdgeInsets
        
        return button
    }

    fileprivate class func customButton(with title: NSAttributedString,
                                        highlightedTitle: NSAttributedString? = nil,
                                        frame: CGRect,
                                        target: Any,
                                        action: Selector) ->  UIButton{
        let button = UIButton(type: .custom)

        button.setAttributedTitle(title, for: .normal)
        button.setAttributedTitle(highlightedTitle, for: .highlighted)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.frame = frame

        return button
    }
}
