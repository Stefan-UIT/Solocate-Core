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

}


struct OrderDetailInforRow {
    var title: String = ""
    var content: String = ""
    var isHighlight = false
    
    
    init(_ title:String , _ content:String, _ isHighlight:Bool = false) {
        self.title = title
        self.content = content
        self.isHighlight = isHighlight
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
    
    
    weak var delegate:OrderDetailTableViewCellDelegate?
    var orderDetailItem: OrderDetailInforRow! {
        didSet {
            nameLabel?.text = orderDetailItem.title
            contentLabel?.text = orderDetailItem.content
            contentLabel?.textColor = orderDetailItem.isHighlight ? AppColor.buttonColor : AppColor.black
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel?.numberOfLines = 0
    }
    
    func setupMapView()  {
        mapView?.isMyLocationEnabled = true
        mapView?.delegate = self
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
