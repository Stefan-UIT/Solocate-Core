import UIKit

public extension UICollectionView {
  public func registerCellClass <CellClass: UICollectionViewCell> (cellClass: CellClass.Type) {
    register(cellClass, forCellWithReuseIdentifier: cellClass.description())
  }

  public func registerCellNibForClass(cellClass: AnyClass) {
    let classNameWithoutModule = cellClass
      .description()
      .components(separatedBy: ".")
      .dropFirst()
      .joined(separator: ".")

    register(UINib(nibName: classNameWithoutModule, bundle: nil),
                forCellWithReuseIdentifier: classNameWithoutModule)
 
  }
}
