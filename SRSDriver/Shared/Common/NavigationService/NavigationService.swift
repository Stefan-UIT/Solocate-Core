
import UIKit

typealias NavigationServiceItemAction = () -> ()

/// Types of navigation items that can be displayed.
enum NavigationItemType {
    case back
    case close
    case menu
}

/// Protocol for setting up the navigation item of a view controller.  This class will listen for in progress orders
//  which can be tracked. An indicator will be shown in the navigation bar if 1 or more orders are trackable.
protocol NavigationService {
    var shouldShowOrderTrackingIndicator: Bool { get set }
    var navigationItem: UINavigationItem? { get set }
    var defaultTitle: String? { get set }

    init()

    func setUp(rightBarButtonItemType: NavigationItemType?,
               rightBarButtonAction: NavigationServiceItemAction?)
    func setUp(leftBarButtonItemType: NavigationItemType?,
               leftBarButtonAction: NavigationServiceItemAction?)

    /// Sets up the navigation item and starts listening for orders to be tracked.
    func start()
    
    /// Performs an optional animation action for the given navigation item type
    func performAnimationAction(for itemType: NavigationItemType)
}


extension NavigationService {
    
    func barButtonItem(for type: NavigationItemType?, target: Any, action: Selector) -> UIBarButtonItem? {
        guard let type = type else {
            return nil
        }
        
        switch type {
        case .back:
            return UIBarButtonItem.back(target: target, action: action)
        case .close:
            return UIBarButtonItem.close(target: target, action: action)
        case .menu:
            return UIBarButtonItem.menu(target: target, action: action)
        }
    }
}
