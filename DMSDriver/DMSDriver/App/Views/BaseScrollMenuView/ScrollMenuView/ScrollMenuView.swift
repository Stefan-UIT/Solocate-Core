

import UIKit

protocol ScrollMenuViewDelagate:class {
    func didSelectItemMenu(view:ScrollMenuView, indexPath:IndexPath)
}

class MenuItem: NSObject {
    var name = ""
    
    init(_ name: String) {
        self.name = name
    }
}

class ScrollMenuView: UIView {
    
    @IBOutlet weak var clvContent:UICollectionView?
    
    weak var delegate:ScrollMenuViewDelagate?
    
    var indexSelect:Int = 0;
    var backgroundCell:UIColor = UIColor.white
    var selectedBackground:UIColor  = UIColor.blue
    var cornerRadiusCell:CGFloat?
    
    var listItems:[MenuItem]?
  
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        clvContent?.delegate = self
        clvContent?.dataSource = self
        clvContent?.registerCellNibForClass(cellClass: ScrollMenuCell.self)
    }
}

extension ScrollMenuView:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listItems?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width / CGFloat(listItems?.count ?? 0)),
                     height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ScrollMenuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScrollMenuCell", for: indexPath) as! ScrollMenuCell
        let  row = indexPath.row
        guard let item = listItems?[row] else {return cell}
        cell.configura(item: item,
                       isSelect: indexSelect == row,
                       backgroundColor: backgroundCell,
                       selectedBackgroundColor: selectedBackground,
                       cornerRadius: cornerRadiusCell)        
        
        return cell;
    }
}

extension ScrollMenuView: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        indexSelect = indexPath.row;
        clvContent?.reloadData()
        
        delegate?.didSelectItemMenu(view: self, indexPath: indexPath)
    }
}

