//
//  MapsViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import GoogleMaps

class MapsViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!

    var route: Route?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        getRouteDetail("\(route?.id ?? 0)")
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setupMapView() {
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
    }
  
    func drawPath(fromLocation from: CLLocationCoordinate2D,
                toLocation to: CLLocationCoordinate2D) {
        self.showLoadingIndicator()
        API().getDirection(fromLocation: from, toLocation: to) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(let obj):
                for route in obj.routes {
                    let path = GMSPath(fromEncodedPath: route.polyline)
                    let polyLine = GMSPolyline.init(path: path)
                    polyLine.strokeWidth = Constants.ROUTE_WIDTH
                    polyLine.strokeColor = AppColor.mainColor
                    polyLine.map = self?.mapView
                    let bounds = GMSCoordinateBounds(path: path!)
                    self?.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
                }
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    func drawPath(fromLocation from: CLLocationCoordinate2D,
                  toLocation to: CLLocationCoordinate2D,
                  wayPoints:Array<CLLocationCoordinate2D>) {
        self.showLoadingIndicator()
        API().getDirection(origin: from,
                           destination: to,
                           waypoints: wayPoints) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(let obj):
                for route in obj.routes {
                    let path = GMSPath(fromEncodedPath: route.polyline)
                    let polyLine = GMSPolyline.init(path: path)
                    polyLine.strokeWidth = Constants.ROUTE_WIDTH
                    polyLine.strokeColor = AppColor.mainColor
                    polyLine.map = self?.mapView
                    let bounds = GMSCoordinateBounds(path: path!)
                    self?.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
                }
            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
    
    
    private func drawMap() {
        guard let _route = route else {
            return
        }
        mapView.clear()
        showMarkers()

        _route.getChunkedListLocation().forEach { (listLocation) in
            if let firstLocation = listLocation.first,
                let lastLocation = listLocation.last  {
                
                let wayPoints = listLocation
                let result = wayPoints.dropFirst()
                let newResult = Array(result.dropLast())
                
                drawPath(fromLocation: firstLocation,
                         toLocation: lastLocation,
                         wayPoints: newResult)
            }
        }
    }
    
    private func labelMarkerWithText(_ text:String) -> UILabel {
        let labelOrder = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        labelOrder.text = text
        labelOrder.textAlignment = .center
        labelOrder.textColor = .white
        labelOrder.backgroundColor = .gray
        labelOrder.cornerRadius = 15.0
        labelOrder.clipsToBounds = true
        
        return labelOrder
    }
    
    
    private func showMarker(_ order:Order, sequence:Int) {
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: order.lat.doubleValue, longitude: order.lng.doubleValue))
        let labelOrder = labelMarkerWithText("\(sequence)")
        marker.title = "\(order.storeName)"
        marker.snippet = "\(order.deliveryAdd)"
        marker.map = mapView
        marker.iconView = labelOrder
        marker.zIndex = 1
    }
    
    private func showMarkers() {
        /*
        guard let wareHouse = route!.warehouse else { return}
        let warehouseMarker = wareHouse.toGMSMarker() // warehouse marker
        */
        if let currentLocationMarker = getGMSMarker(){
            currentLocationMarker.map = mapView
        }
        
        let distinctArray = route!.distinctArrayOrderList()
        for (index,order) in distinctArray.enumerated() {
            let seq = index + 1
            showMarker(order, sequence:seq)
        }
    }
    
    func getGMSMarker() -> GMSMarker? {
        guard let currentLocation = LocationManager.shared.currentLocation?.coordinate else {
            LocationManager.shared.requestLocation()
            return nil
        }
        return GMSMarker(position: currentLocation)
    }
}

extension MapsViewController: GMSMapViewDelegate {
  
}

//MARK: - MapsViewController
extension MapsViewController{
    func getRouteDetail(_ routeID:String, isFetch:Bool = false) {
        if !isFetch {
            self.showLoadingIndicator()
        }
        API().getRouteDetail(route: routeID) {[weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.dismissLoadingIndicator()
            
            switch result{
            case .object(let obj):
                strongSelf.route = obj
                strongSelf.drawMap()
                
            case .error(let error):
                strongSelf.showAlertView(error.getMessage())
                
            }
        }
    }
}
