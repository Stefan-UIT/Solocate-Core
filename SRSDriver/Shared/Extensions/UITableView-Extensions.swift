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
  public func registerCellClass <CellClass: UITableViewCell> (cellClass: CellClass.Type) {
    register(cellClass, forCellReuseIdentifier: cellClass.description())
  }

  public func registerCellNibForClass(cellClass: AnyClass) {
    let classNameWithoutModule = cellClass
      .description()
      .components(separatedBy: ".")
      .dropFirst()
      .joined(separator: ".")

    register(UINib(nibName: classNameWithoutModule, bundle: nil),
                forCellReuseIdentifier: classNameWithoutModule)
  }
  
  
}
