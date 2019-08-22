//
//  OrderDetailTableViewCell.swift
//  SRSDriver
//
//  Created by phunguyen on 3/16/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import GoogleMaps

protocol OrderDetailTableViewCellDelegate:class {
    func didSelectedDopdown(_ cell:OrderDetailTableViewCell,_ btn:UIButton)
    func didSelectEdit(_ cell:OrderDetailTableViewCell,_ btn:UIButton)
    func didSelectGo(_ cell:OrderDetailTableViewCell,_ btn:UIButton)
    func didEnterPalletsQuantityTextField(_ cell:OrderDetailTableViewCell, value:String, detail:Order.Detail)
    func didEnterCartonsQuantityTextField(_ cell:OrderDetailTableViewCell, value:String, detail:Order.Detail)
}


struct OrderDetailInforRow {
    var title: String = ""
    var content: String = ""
    var isHighlight = false
    var textColor:UIColor?
    
    
    init(_ title:String , _ content:String, _ isHighlight:Bool = false, _ textColor:UIColor? = nil ) {
        self.title = title
        self.content = content
        self.isHighlight = isHighlight
        self.textColor = textColor
    }
}


class OrderDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var contentLabel: UILabel?
    @IBOutlet weak var lblBarcode: UILabel?
    @IBOutlet weak var lblPackgage: UILabel?
    @IBOutlet weak var iconImgView: UIImageView?
    @IBOutlet weak var lineView: UIView?
    @IBOutlet weak var vContent: UIView?
    @IBOutlet weak var btnEdit: UIButton?
    @IBOutlet weak var btnStatus: UIButton?
    @IBOutlet weak var btnGo: UIButton?
    @IBOutlet weak var mapView: GMSMapView?
    
    @IBOutlet weak var actualQuantityTextField: UITextField?
    @IBOutlet weak var actualCartonsInPalletTextField: UITextField?
    
    @IBOutlet weak var cartonInPalletsLabel: UILabel?
    @IBOutlet weak var cartonInPalletViewContainer: UIView?
    
    
    @IBOutlet weak var cartonsViewContainerHeightConstraint: NSLayoutConstraint?
    
    
    @IBOutlet weak var palletsViewContainerHeightConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var cartonsViewContainerTopSpacing: NSLayoutConstraint?
    
    
    @IBOutlet weak var deliveredQtyStaticLabel: UILabel?
    @IBOutlet weak var deliveredCartonsStaticLabel: UILabel?
    
    @IBOutlet weak var wmsOrderCodeViewContainer: UIView?
    
    @IBOutlet weak var wmsMainifestNumberViewContainer: UIView?
    
    @IBOutlet weak var wmsOrderCodeHeightConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var wmsManifestHeightConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var wmsOrderCodeLabel: UILabel?
    
    @IBOutlet weak var wmsOrderManifestNumberLabel: UILabel?
    
    @IBOutlet weak var wmsOrderCodeTopSpacing: NSLayoutConstraint?
    
    @IBOutlet weak var wmsManifestContainerTopSpacing: NSLayoutConstraint?
    
    
    @IBOutlet weak var loadedQtyViewContainer: UIView?
    
    @IBOutlet weak var loadedQtyContainerHeightConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var loadedQtyTopSpaceConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var loadedCartonsLabel: UILabel?
    @IBOutlet weak var loadedQuantityLabel: UILabel?
    
    @IBOutlet weak var returnedPalletsLabel: UILabel?
    
    @IBOutlet weak var loadedCartonsQtyViewContainer: UIView?
    
    @IBOutlet weak var loadedPickUpQtyContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loadedPickUpLabel: UILabel!
    
    
    weak var delegate:OrderDetailTableViewCellDelegate?
    var orderDetailItem: OrderDetailInforRow! {
        didSet {
            nameLabel?.text = orderDetailItem.title
            contentLabel?.text = orderDetailItem.content
            contentLabel?.textColor = orderDetailItem.isHighlight ? AppColor.buttonColor : AppColor.black
            if let color = orderDetailItem.textColor {
                contentLabel?.textColor = color
            }
        }
    }
    
    var detail:Order.Detail!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel?.numberOfLines = 0
        guard let palletTextField = actualQuantityTextField, let cartonTextField = actualCartonsInPalletTextField else { return }
        palletTextField.delegate = self
        cartonTextField.delegate = self
    }
    
    func setupMapView()  {
        mapView?.isMyLocationEnabled = true
        mapView?.delegate = self
    }
    
    func handleShowingDeliveredQtyRecored(isHidden:Bool) {
        deliveredQtyStaticLabel?.isHidden = isHidden
        actualQuantityTextField?.isHidden = isHidden
    }
    
    func handleShowingDeliveredCartonsRecord(isHidden:Bool) {
        deliveredCartonsStaticLabel?.isHidden = isHidden
        actualCartonsInPalletTextField?.isHidden = isHidden
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func onbtnClickDropdown(btn:UIButton){
        delegate?.didSelectedDopdown(self, btn)
    }
    
    @IBAction func onbtnClickEdit(btn:UIButton){
        delegate?.didSelectEdit(self, btn)
    }
    
    @IBAction func onbtnClickGo(btn:UIButton){
        delegate?.didSelectGo(self, btn)
    }
    
    func drawRouteMap(order:Order?) {
        setupMapView()
        mapView?.clear()
        showAllMarker(order: order)
        if order?.directionRoute == nil {
            drawDirections(order: order)
        }else {
            for route in order?.directionRoute ?? [] {
                mapView?.drawPath(directionRoute: route)
            }
        }
    }
}

// MARK: - PRIVATE FUNTIONS
extension OrderDetailTableViewCell {
    private func drawDirections(order:Order?)  {
        order?.getChunkedListLocation().forEach { (listLocation) in
            if let firstLocation = listLocation.first,
                let lastLocation = listLocation.last  {
                
                let wayPoints = listLocation
                let result = wayPoints.dropFirst()
                let newResult = Array(result.dropLast())
                
                mapView?.drawPath(fromLocation: firstLocation,
                                  toLocation: lastLocation,
                                  wayPoints: newResult,
                                  complation: { (success, directionRoutes) in
                                    order?.directionRoute = directionRoutes
                })
            }
        }
    }
    
    private  func showAllMarker(order:Order?) {
        if let from = order?.from,
            let lat = from.lattd?.doubleValue,
            let lng = from.lngtd?.doubleValue  {
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            mapView?.showMarker(type: .From,
                                location: location,
                                name: order?.from?.name,
                                snippet:  order?.from?.ctt_phone)
        }
        
        if let to = order?.to,
            let lat = to.lattd?.doubleValue,
            let lng = to.lngtd?.doubleValue  {
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            mapView?.showMarker(type: .To,
                                location: location,
                                name: order?.to?.name,
                                snippet:  order?.from?.ctt_phone)
        }
    }
}

//MARK: - GMSMapViewDelegate
extension OrderDetailTableViewCell: GMSMapViewDelegate {
    
}

//MARK: - UITEXTFIELD
extension OrderDetailTableViewCell: UITextFieldDelegate {
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        guard let palletTextField = actualQuantityTextField, let cartonTextField = actualCartonsInPalletTextField else { return }
//        let text =  textField.text ?? ""
//        if textField == palletTextField {
//            delegate?.didEnterPalletsQuantityTextField(self, value: text, detail: self.detail)
//        } else if textField == cartonTextField {
//            delegate?.didEnterCartonsQuantityTextField(self, value: text, detail: self.detail)
//        }
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            guard let palletTextField = actualQuantityTextField, let cartonTextField = actualCartonsInPalletTextField else { return true }
            if textField == palletTextField {
                delegate?.didEnterPalletsQuantityTextField(self, value: updatedText, detail: self.detail)
            } else if textField == cartonTextField {
                delegate?.didEnterCartonsQuantityTextField(self, value: updatedText, detail: self.detail)
            }
        }
        return true
    }
}
