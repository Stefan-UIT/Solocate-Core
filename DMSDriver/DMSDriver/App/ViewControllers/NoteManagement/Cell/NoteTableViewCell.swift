//
//  NoteTableViewCell.swift
//  DMSDriver
//
//  Created by Trung Vo on 6/6/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var attachedFilesLabel: UILabel!
    @IBOutlet weak var attachedFilesButton: Button!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var note:Note!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        statusButton.borderWidth = 1.0
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func shouldHideAttachedFilesSection(isHidden:Bool) {
        self.attachedFilesLabel.isHidden = isHidden
        self.attachedFilesButton.isHidden = isHidden
    }
    
    func configureCell(note:Note) {
        self.note = note
        self.collectionView.reloadData()
        self.authorNameLabel.text = note.user.userName ?? ""
        self.contentLabel.text = note.content
        self.timeLabel.text = note.createdAt
        let numberOfAttachedFiles = note.files.count
        shouldHideAttachedFilesSection(isHidden: numberOfAttachedFiles==0)
        if numberOfAttachedFiles > 0 {
            self.attachedFilesLabel.text = (numberOfAttachedFiles > 1) ? "\(numberOfAttachedFiles) attached files" : "\(numberOfAttachedFiles) attached file"
        }
        
        
        let statusOrder = StatusOrder(rawValue: note.status.code ?? "OP")
        statusButton.borderColor = statusOrder?.color
        statusButton.setTitle(statusOrder?.statusName, for: .normal)
        statusButton.setTitleColor(statusOrder?.color, for: .normal)
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
        let cellWidth = floor((collectionView.frame.size.width) / 3.0);
        let cellHeight = floor(collectionView.frame.size.height / 2);
        
        let size = CGSize(width:cellWidth,height: cellHeight);
        return size;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell
        let file  = note.files[indexPath.row]
        cell?.imageView.sd_setImage(with: URL(string: E(file.url_thumbnail)),
                                    placeholderImage: #imageLiteral(resourceName: "place_holder"),
                                    options: .refreshCached, completed: nil)
        
        return cell!
    }
    
    
}
