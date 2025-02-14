//
//  OrderDetailMapViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/16/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import GoogleMaps

class OrderDetailMapViewController: BaseViewController {
  
    @IBOutlet weak var vMapContent: UIView?
    @IBOutlet weak var tableView: UITableView!
    
    
    fileprivate var steps = [DirectionStep]()
    fileprivate let cellIdentifier = "OrderDetailMapTableViewCell"
    
    var orderLocation: CLLocationCoordinate2D?
    var orderDetail: Order?
    var mapView:GMSMapView?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        drawRoute()
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func updateNavigationBar() {
        App().navigationService.delegate = self
        //App().navigationService.updateNavigationBar(.BackOnly, "Map")
        App().navigationService.updateNavigationBar(.Menu,
                                                    "Map".localized,
                                                    AppColor.white, true)

    }
    
    override func updateUI() {
        super.updateUI()
        DispatchQueue.main.async {[weak self] in
            self?.setupMapView()
            self?.updateNavigationBar()
            self?.setupTableView()
        }
    }
    
    func setupTableView()  {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80.0
    }
    
    func setupMapView()  {
        guard let userLocation = LocationManager.shared.currentLocation else {
                LocationManager.shared.delegate = self
                LocationManager.shared.requestLocation()
                return
        }
        mapView = GMSMapView.map(withFrame: self.vMapContent?.frame ?? CGRect.zero, camera: GMSCameraPosition.camera(withLatitude:userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 3))
        
        mapView?.center = self.vMapContent?.center ?? CGPoint.zero
        vMapContent?.addSubview(mapView!)
        mapView?.isMyLocationEnabled = true
        
        if let _locattion = orderLocation {
            mapView?.animate(toLocation: _locattion)
            showAllMarker(order: orderDetail)
            /*
            let marker = GMSMarker(position: _locattion)
            marker.map = mapView
             */
        }
    }
    
    private  func showAllMarker(order:Order?) {
        if let from = order?.from,
            let lat = from.lattd?.doubleValue,
            let lng = from.lngtd?.doubleValue  {
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            mapView?.showMarker(type: .Pickup,
                                location: location,
                                name: order?.from?.name,
                                snippet:  order?.from?.ctt_phone)
        }
        
        if let to = order?.to,
            let lat = to.lattd?.doubleValue,
            let lng = to.lngtd?.doubleValue  {
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            mapView?.showMarker(type: .Delivery,
                                location: location,
                                name: order?.to?.name,
                                snippet:  order?.from?.ctt_phone)
        }
    }
    
    func drawRoute() {
        guard let userLocation = LocationManager.shared.currentLocation,
            let _locattion = orderLocation else {
                LocationManager.shared.delegate = self
                LocationManager.shared.requestLocation()
                return
        }
        getDirection(from: userLocation.coordinate, toLocation: _locattion)
    }
}

extension OrderDetailMapViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return steps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderDetailMapTableViewCell {
          cell.step = steps[indexPath.row]
          return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: view.frame.width, height: 1.0), animated: true)
        let step = steps[indexPath.row]
        let bearing = getBearingBetweenTwoPoints(point1: step.startLocation.toCoordinate(), point2: step.endLocation.toCoordinate())
        let cameraPosition = GMSCameraPosition(target: step.startLocation.toCoordinate(), zoom: 16.0, bearing: bearing, viewingAngle: 30.0)
        mapView?.animate(to: cameraPosition)
    }
}

extension OrderDetailMapViewController: LocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //
    }
    
    func didUpdateLocation(_ location: CLLocation?) {
        guard let userLocation = location, let destinationLocation = orderLocation else {
          return
        }
        getDirection(from: userLocation.coordinate, toLocation: destinationLocation)
    }
}

extension OrderDetailMapViewController {
  func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
  func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
  
  func getBearingBetweenTwoPoints(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {
    
    let lat1 = degreesToRadians(degrees: point1.latitude)
    let lon1 = degreesToRadians(degrees: point1.longitude)
    
    let lat2 = degreesToRadians(degrees: point2.latitude)
    let lon2 = degreesToRadians(degrees: point2.longitude)
    
    let dLon = lon2 - lon1
    
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    let radiansBearing = atan2(y, x)
    
    return radiansToDegrees(radians: radiansBearing)
  }
    
  func getDirection(from fromLocation: CLLocationCoordinate2D, toLocation: CLLocationCoordinate2D) {
    self.showLoadingIndicator()
    SERVICES().API.getDirection(fromLocation: fromLocation, toLocation: toLocation) {[weak self] (result) in
        self?.dismissLoadingIndicator()
        switch result{
        case .object(let obj):
            let _routes = obj.routes
            guard let firstRoute = _routes.first else {
                return
            }

            let path = GMSPath(fromEncodedPath: firstRoute.polyline)
            let polyLine = GMSPolyline.init(path: path)
            polyLine.strokeWidth = Constants.ROUTE_WIDTH
            polyLine.strokeColor = AppColor.mainColor
            polyLine.map = self?.mapView
            let bounds = GMSCoordinateBounds(path: path!)
            self?.mapView?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))

            //
            self?.steps.removeAll()
            guard let firstLeg = firstRoute.legs.first else {return}
            self?.steps.append(contentsOf: firstLeg.steps)
            self?.tableView.reloadData()
            break
        case .error(let error):
            self?.showAlertView(error.getMessage())
            break

        }
     }
  }
}

extension OrderDetailMapViewController:DMSNavigationServiceDelegate{
    
    func didSelectedBackOrMenu() {
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
}
