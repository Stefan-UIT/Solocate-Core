//
//  NoteTableViewCell.swift
//  DMSDriver
//
//  Created by Trung Vo on 6/6/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

protocol NoteTableViewCellDelegate: class {
    func didTouchOnCollectionView(_ note:Note)
}

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var attachedFilesLabel: UILabel!
    @IBOutlet weak var attachedFilesButton: Button!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomSpace: NSLayoutConstraint!
    weak var delegate: NoteTableViewCellDelegate?
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    
    var note:Note!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        statusButton.borderWidth = 1.0
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func shouldHideAttachedFilesSection(isHidden:Bool) {
        self.attachedFilesLabel.isHidden = isHidden
        self.attachedFilesButton.isHidden = isHidden
    }
    
    func handleShowingCollectionViewImages() {
        let isHasFiles = note.files.count > 0
        self.collectionViewHeightConstraint.constant = (isHasFiles) ? 75.0 : 0.0
        self.collectionViewBottomSpace.constant = (isHasFiles) ? 16.0 : 0.0
    }
    
    func configureCell(note:Note) {
        self.note = note
        handleShowingCollectionViewImages()
        self.collectionView.reloadData()
        self.authorNameLabel.text = note.createdBy.userName
        self.contentLabel.text = note.content
        self.timeLabel.text = displayedStringDate(from:note.createdAt)
        let numberOfAttachedFiles = note.files.count
//        shouldHideAttachedFilesSection(isHidden: numberOfAttachedFiles==0)
        shouldHideAttachedFilesSection(isHidden: true)
        if numberOfAttachedFiles > 0 {
            self.attachedFilesLabel.text = (numberOfAttachedFiles > 1) ? "\(numberOfAttachedFiles) attached files" : "\(numberOfAttachedFiles) attached file"
        }
        
        let statusOrder = StatusOrder(rawValue: note.status.code ?? "OP")
//        statusButton.borderColor = statusOrder?.color
//        statusButton.setTitle(statusOrder?.statusName, for: .normal)
//        statusButton.setTitleColor(statusOrder?.color, for: .normal)
        statusButton.setTitle(statusOrder?.statusName.localized, for: .normal)
        statusButton.backgroundColor = statusOrder?.color
        statusButton.borderColor = statusOrder?.color
        statusButton.setTitleColor(.white, for: .normal)
        statusButton.cornerRadius = 10.0
    }
    
    func displayedStringDate(from dateStr:String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM d, h:mm a"
        
        if let date = dateFormatterGet.date(from: dateStr) {
            return (dateFormatterPrint.string(from: date))
        }
        return ""
    }

}

extension NoteTableViewCell:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return note.files.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = self.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return sectionInsets
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return sectionInsets.left
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell
        let file  = note.files[indexPath.row]
        cell?.imageView.sd_setImage(with: URL(string: E(file.url_thumbnail)),
                                    placeholderImage: #imageLiteral(resourceName: "place_holder"),
                                    options: .refreshCached, completed: nil)
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        delegate?.didTouchOnCollectionView(note)
    }
    
    
}
