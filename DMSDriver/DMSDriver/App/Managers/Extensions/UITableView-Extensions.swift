import UIKit

protocol Reusable: class {
  static var reuseIdentifier: String { get }
}

extension Reusable {
  static var reuseIdentifier: String {
    return String(describing: Self.self)
  }
}

public extension UITableView {
     func registerCellClass <CellClass: UITableViewCell> (cellClass: CellClass.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.description())
    }

    func registerCellNibForClass(cellClass: AnyClass) {
        let classNameWithoutModule = cellClass
            .description()
            .components(separatedBy: ".")
            .dropFirst()
            .joined(separator: ".")

        register(UINib(nibName: classNameWithoutModule, bundle: nil),
                forCellReuseIdentifier: classNameWithoutModule)
    }
    
    func addRefreshControl(_ target: Any?, action: Selector) {
        let refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 40))
        refreshControl.attributedTitle = NSAttributedString(string: "pull-to-refresh".localized)
        refreshControl.addTarget(target, action: action, for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    func isRefreshing() -> Bool {
        return self.refreshControl?.isRefreshing ?? false
    }
    
    func endRefreshControl() {
        self.refreshControl?.endRefreshing()
    }
}
