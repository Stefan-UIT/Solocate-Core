//
//  RentingOrderDetailTableViewCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 9/24/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

enum UpdateStatusButton {
    case START_RENTING_ORDER
    case FINISH_RENTING_ORDER
}

protocol RentingOrderDetailTableViewCellDelegate: NSObjectProtocol {
    func updateStatus(itemId:Int, nextStatus: Int)
    func cancelOrder(itemId:Int, nextStatus: Int)
}

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
    
    @IBOutlet weak var detailStatusLabel: UILabel!
    @IBOutlet weak var vActionView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var positiveButton: UIButton!
    @IBOutlet var vActionViewHeightConstant:NSLayoutConstraint!
    var typeUpdateBtn: UpdateStatusButton = .START_RENTING_ORDER
    weak var delegate: RentingOrderDetailTableViewCellDelegate?
    
    let V_ACTION_VIEW_HEIGHT_CONSTRAINT:CGFloat = 50
    
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
        skulistLabel.text = Slash(rentingOrderDetail.skulist)
        driverLabel.text = Slash(rentingOrderDetail.driver?.userName)
        guard let _status = rentingOrderDetail.status else { return }
        detailStatusLabel.text = _status.name
        detailStatusLabel.textColor = RentingOrderDetailStatusCode(rawValue: _status.code!)?.color
        updateStatusButtonView()
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
    
    func isAssignedToDriver(_ driverId: Int?) -> Bool {
        if Caches().user?.userInfo?.id == driverId {
            return true
        } else {
            return false
        }
    }
    
    func updateStatusButtonView() {
        cancelButton.setTitle("Cancel".localized.uppercased(), for: .normal)
        cancelButton.backgroundColor = AppColor.redColor
        if isAssignedToDriver(rentingOrderDetail.driverId) {
            if rentingOrderDetail?.status?.id == RentingOrderDetailStatusCode.InProgress.code {
                positiveButton.setTitle("Finish".localized.uppercased(), for: .normal)
                positiveButton.backgroundColor = AppColor.greenColor
                typeUpdateBtn = .FINISH_RENTING_ORDER
                self.handleShowingUpdateStatusView(true)
            } else if rentingOrderDetail?.status?.id == RentingOrderDetailStatusCode.NewStatus.code {
                positiveButton.setTitle("Start".localized.uppercased(), for: .normal)
                positiveButton.backgroundColor = AppColor.greenColor
                self.handleShowingUpdateStatusView(true)
                typeUpdateBtn = .START_RENTING_ORDER
            } else if rentingOrderDetail?.status?.id == RentingOrderDetailStatusCode.Finished.code || rentingOrderDetail?.status?.id == RentingOrderDetailStatusCode.Cancelled.code {
                self.handleShowingUpdateStatusView(false)
            }
        } else {
            self.handleShowingUpdateStatusView(false)
        }
    }
    
    func handleShowingUpdateStatusView(_ isShow: Bool) {
        vActionView.isHidden = !isShow
        vActionViewHeightConstant.constant = isShow ? V_ACTION_VIEW_HEIGHT_CONSTRAINT : 0
    }
    
    // MARK: - Action
    @IBAction func didTapUpdateStatusButton(_ sender: Any) {
        switch typeUpdateBtn {
        case .START_RENTING_ORDER:
            self.delegate?.updateStatus(itemId: rentingOrderDetail.id, nextStatus: RentingOrderDetailStatusCode.InProgress.code)
        case .FINISH_RENTING_ORDER:
            self.delegate?.updateStatus(itemId: rentingOrderDetail.id, nextStatus: RentingOrderDetailStatusCode.Finished.code)
        }
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.delegate?.cancelOrder(itemId: rentingOrderDetail.id, nextStatus: RentingOrderDetailStatusCode.Cancelled.code)
    }
    
}
