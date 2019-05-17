//
//  LoadUnLoadListCell.swift
//  DMSDriver
//
//  Created by Apple on 5/16/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

protocol LoadUnLoadListCellDelegate:AnyObject {
    func didSelectedLoadUnload(cell:LoadUnLoadListCell,orderDetail:Order.Detail?)
}

class LoadUnLoadListCell: UITableViewCell {
    
    @IBOutlet weak var lblPackage:UILabel?
    @IBOutlet weak var lblQty:UILabel?
    @IBOutlet weak var lblBarCode:UILabel?
    @IBOutlet weak var lblPackageRefId:UILabel?
    @IBOutlet weak var vContent:UIView?
    @IBOutlet weak var btnLoadUnload:UIButton?

    weak var delegate:LoadUnLoadListCellDelegate?
    

    private var orderDetail:Order.Detail?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configura(orderDetail:Order.Detail) {
        self.orderDetail = orderDetail
        lblPackage?.text = orderDetail.package?.name
        lblQty?.text = #"\#(orderDetail.qty ?? 0)"#
        lblBarCode?.text = orderDetail.barCode
        lblPackageRefId?.text = #"\#( orderDetail.packageRefId ?? 0)"#
        
        btnLoadUnload?.setStyleBlueSquare()
        btnLoadUnload?.setTitle(orderDetail.status.name, for: .normal)
        /*
        switch orderDetail.status {
        case .NotLoad:
            btnLoadUnload?.setTitle("Load".localized, for: .normal)
        case .Loaded:
            btnLoadUnload?.setTitle("Unload".localized, for: .normal)
        case .Unload:
            btnLoadUnload?.setTitle("Load".localized, for: .normal)
        }
         */
    }
    
    //MARK : - Action
    @IBAction func onbtnClickLoadUnload(btn:UIButton){
        delegate?.didSelectedLoadUnload(cell: self, orderDetail: orderDetail)
    }
}
