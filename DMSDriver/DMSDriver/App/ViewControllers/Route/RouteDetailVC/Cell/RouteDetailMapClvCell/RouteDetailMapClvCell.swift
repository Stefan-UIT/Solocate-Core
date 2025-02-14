//
//  RouteDetailMapClvCell.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 3/14/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import GoogleMaps


class RouteDetailMapClvCell: UICollectionViewCell {
    
    private var groupLocationList:[GroupLocatonModel] = []
    
    var mapView: GMSMapView?
    
    var route: Route?{
        didSet{
            initData()
            drawMap()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.perform(#selector(setupMapView),on: Thread.main,with: nil,waitUntilDone: false)
        self.drawMap()
    }
    
    func initData() {
        groupLocationList = route?.sortedGroupingLocationList() ?? []
    }

    @objc func setupMapView() {
        if mapView == nil {
            // Create a map.
            mapView = GMSMapView(frame: self.bounds)
            mapView?.isMyLocationEnabled = true
            mapView?.delegate = self
            mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            guard let map = mapView else {return}
            self.addSubview(map)
        }
    }
    
    func drawPath(fromLocation from: CLLocationCoordinate2D,
                  toLocation to: CLLocationCoordinate2D) {
        SERVICES().API.getDirection(fromLocation: from, toLocation: to) {[weak self] (result) in
            switch result{
            case .object(let obj):
                for route in obj.routes {
                    let path = GMSPath(fromEncodedPath: route.polyline)
                    let polyLine = GMSPolyline.init(path: path)
                    polyLine.strokeWidth = Constants.ROUTE_WIDTH
                    polyLine.strokeColor = AppColor.mainColor
                    polyLine.map = self?.mapView
                    let bounds = GMSCoordinateBounds(path: path!)
                    self?.mapView?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
                }
            case .error(let error):
                //self?.showAlertView(error.getMessage())
                break
            }
        }
    }
    
    func drawPath(fromLocation from: CLLocationCoordinate2D,
                  toLocation to: CLLocationCoordinate2D,
                  wayPoints:Array<CLLocationCoordinate2D>) {
        //self.showLoadingIndicator()
        SERVICES().API.getDirection(origin: from,
                           destination: to,
                           waypoints: wayPoints) {[weak self] (result) in
                            //self?.dismissLoadingIndicator()
                            switch result{
                            case .object(let obj):
                                for route in obj.routes {
                                    let path = GMSPath(fromEncodedPath: route.polyline)
                                    let polyLine = GMSPolyline.init(path: path)
                                    polyLine.strokeWidth = Constants.ROUTE_WIDTH
                                    polyLine.strokeColor = AppColor.mainColor
                                    polyLine.map = self?.mapView
                                    let bounds = GMSCoordinateBounds(path: path!)
                                    self?.mapView?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
                                }
                            case .error(let error):
                                //self?.showAlertView(error.getMessage())
                                break
                            }
        }
    }
    
    
    private func drawMap() {
        guard let _route = route else {
            return
        }
        mapView?.clear()
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
    
    
    private func showMarker(_ location:GroupLocatonModel, sequence:Int) {
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: location.address?.lattd?.doubleValue ?? 0,
                                                                longitude: location.address?.lngtd?.doubleValue ?? 0))
        let labelOrder = labelMarkerWithText("\(sequence)")
        marker.title = "Deliver: PACK1, PACK2, PACK3"
        marker.snippet = "Pickup: PACK4"
        marker.map = mapView
        marker.iconView = labelOrder
        marker.zIndex = 1
        marker.userData = location
    }
    
    private func showMarkers() {
        /*
         guard let wareHouse = route!.warehouse else { return}
         let warehouseMarker = wareHouse.toGMSMarker() // warehouse marker
         */
        guard let _route = route else {
            return
        }
        
        //let distinctArray = _route.getListLocations()
        for (index,location) in groupLocationList.enumerated() {
            let seq = index + 1
            showMarker(location, sequence:seq)
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


//MARK: - GMSMapViewDelegate
extension RouteDetailMapClvCell: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let location = marker.userData as? GroupLocatonModel else {
            return false
        }
        LocationDetailView.showLocationViewDetail(at: App().mainVC, location: location)

        return true
    }
}

//MARK: - MapsViewController
extension RouteDetailMapClvCell{
    func getRouteDetail(_ routeID:String, isFetch:Bool = false) {
        if !isFetch {
           // self.showLoadingIndicator()
        }
        SERVICES().API.getRouteDetail(route: routeID) {[weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            //strongSelf.dismissLoadingIndicator()
            
            switch result{
            case .object(let obj):
                strongSelf.route = obj.data
                strongSelf.drawMap()
                
            case .error(let error):
                //strongSelf.showAlertView(error.getMessage())
                break
            }
        }
    }
}
