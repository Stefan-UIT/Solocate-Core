import UIKit

public extension UICollectionView {
    func registerCellClass <CellClass: UICollectionViewCell> (cellClass: CellClass.Type) {
        register(cellClass, forCellWithReuseIdentifier: cellClass.description())
    }

    func registerCellNibForClass(cellClass: AnyClass) {
        let classNameWithoutModule = cellClass
          .description()
          .components(separatedBy: ".")
          .dropFirst()
          .joined(separator: ".")

        register(UINib(nibName: classNameWithoutModule, bundle: nil),
                    forCellWithReuseIdentifier: classNameWithoutModule)

    }
    
    func addPullToRefetch(_ target: UIViewController, action: Selector)  {
        let refreshControl:UIRefreshControl = UIRefreshControl()
        refreshControl.tintColor =  UIColor.gray
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localized)
        refreshControl.addTarget(target, action: action, for: UIControl.Event.valueChanged)
        //self.addSubview(refreshControl)
        self.refreshControl = refreshControl
        self.alwaysBounceVertical = true
    }
    
    
    func isRefreshing() -> Bool {
        return self.refreshControl?.isRefreshing ?? false
    }
    
    func endRefreshControl() {
        self.refreshControl?.endRefreshing()
    }
}
