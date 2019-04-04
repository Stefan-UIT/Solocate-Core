//
//  FilterDataListInsertRowCell.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 2/19/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

protocol FilterDataListInsertRowCellDelegate:AnyObject {
    func filterDataListInsertRowCell(cell:FilterDataListInsertRowCell, didSelect indexPath:IndexPath)
}

class FilterDataListInsertRowCell: UITableViewCell {
    
    @IBOutlet weak var tbvContent:UITableView?
    
    private let identifierCell = "FilterDataListInsertContentCell"

    var dataSource:[String] = [] {
        didSet{
            tbvContent?.reloadData()
        }
    }
    weak var delegate:FilterDataListInsertRowCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupTableView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundedCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner], 10)
        self.layer.borderWidth = 0.7;
        self.layer.borderColor = AppColor.grayBorderColor.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupTableView()  {
        tbvContent?.delegate = self
        tbvContent?.dataSource = self
        tbvContent?.register(UINib.init(nibName: ClassName(FilterDataListInsertContentCell()),
                                        bundle: nil), forCellReuseIdentifier: identifierCell)
    }
}

//MARK: - UITableView
extension FilterDataListInsertRowCell:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath) as! FilterDataListInsertContentCell
        cell.lblTitle?.text = dataSource[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.filterDataListInsertRowCell(cell: self, didSelect: indexPath)
    }
}
