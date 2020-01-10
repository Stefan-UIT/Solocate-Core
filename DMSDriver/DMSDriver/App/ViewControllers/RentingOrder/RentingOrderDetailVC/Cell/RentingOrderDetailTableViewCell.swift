//
//  RentingOrderDetailTableViewCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 9/24/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit


class RentingOrderDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var truckTypeLabel: UILabel!
    @IBOutlet weak var truckLabel: UILabel!
    @IBOutlet weak var trailerTankerTypeLabel: UILabel!
    @IBOutlet weak var tankerLabel: UILabel!
    @IBOutlet weak var trailerTankerType2Label: UILabel!
    @IBOutlet weak var tanker2Label: UILabel!
    @IBOutlet weak var skulistLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var trailerTankerTypeView: UIView!
    @IBOutlet weak var tankerView: UIView!
    @IBOutlet weak var trailerTankerType2View: UIView!
    @IBOutlet weak var tanker2View: UIView!
    
    @IBOutlet weak var trailerTankerType2NameLabel: UILabel!
    @IBOutlet weak var tanker2NameLabel: UILabel!
    var rentingOrderDetail:RentingOrder.RentingOrderDetail!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCellWithRentingOrderDetail(_ rentingOrderDetail: RentingOrder.RentingOrderDetail) {
        trailerTankerType2NameLabel.text = "trailer-tanker-type".localized + " 2"
        tanker2NameLabel.text = "Tanker".localized + " 2"
        let tanker1Index = 0
        let tanker2Index = 1
        tanker2View.isHidden = true
        trailerTankerType2View.isHidden = true
        
        // Handle Show Tanker/Tanker2 and TrailerTankerType/TrailerTankerType2
        if rentingOrderDetail.tanker?.tankers?.count == 0 || rentingOrderDetail.tanker?.tankers == nil{
            tankerView.isHidden = true
        } else if rentingOrderDetail.tanker?.tankers?.count == 1 {
            tankerView.isHidden = false
            tankerLabel.text = tankerPlateNum(with: tanker1Index, rentingOrderDetail: rentingOrderDetail)
        } else if rentingOrderDetail.tanker?.tankers?.count > 1 && rentingOrderDetail.tanker?.tankers?.last != nil {
            tankerView.isHidden = false
            tankerLabel.text = tankerPlateNum(with: tanker1Index, rentingOrderDetail: rentingOrderDetail)
            tanker2View.isHidden = false
            tanker2Label.text = tankerPlateNum(with: tanker2Index, rentingOrderDetail: rentingOrderDetail)
        } else if rentingOrderDetail.tanker?.tankers?.count > 1 && rentingOrderDetail.tanker?.tankers?.last == nil {
            tanker2View.isHidden = true
        }
        
        if rentingOrderDetail.tanker?.tankerType?.count == 0 || rentingOrderDetail.tanker?.tankerType == nil{
            trailerTankerTypeView.isHidden = true
        } else if rentingOrderDetail.tanker?.tankerType?.count == 1 {
            trailerTankerTypeView.isHidden = false
            trailerTankerTypeLabel.text = trailerTankerTypeName(with: tanker1Index, rentingOrderDetail: rentingOrderDetail)
        } else if rentingOrderDetail.tanker?.tankerType?.count > 1 || rentingOrderDetail.tanker?.tankerType?.last != nil {
            trailerTankerTypeView.isHidden = false
            trailerTankerTypeLabel.text = trailerTankerTypeName(with: tanker1Index, rentingOrderDetail: rentingOrderDetail)
            trailerTankerType2View.isHidden = false
            trailerTankerType2Label.text = trailerTankerTypeName(with: tanker2Index, rentingOrderDetail: rentingOrderDetail)
        } else if rentingOrderDetail.tanker?.tankerType?.count > 1 && rentingOrderDetail.tanker?.tankerType?.last == nil {
            trailerTankerType2View.isHidden = true
        }
        
        truckTypeLabel.text = rentingOrderDetail.truckType?.name
        truckLabel.text = Slash(rentingOrderDetail.truck?.plateNum)
        skulistLabel.text = rentingOrderDetail.skulist
        driverLabel.text = rentingOrderDetail.driver?.userName
    }
    
    
    func tankerPlateNum(with index:Int, rentingOrderDetail: RentingOrder.RentingOrderDetail) -> String {
        var result = ""
        result = Slash(rentingOrderDetail.tanker?.tankers?[index].plateNum)
        return result
    }
    
    func trailerTankerTypeName(with index:Int, rentingOrderDetail: RentingOrder.RentingOrderDetail) -> String {
        var result = ""
        result = Slash(rentingOrderDetail.tanker?.tankerType?[index].name)
        return result
    }
}
