//
//  GMSMapview+Ext.swift
//  DMSDriver
//
//  Created by Mach Van  Nguyen on 4/2/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation
import GoogleMaps

enum MarkerType {
    case Normal
    case From
    case To
    case Port
}

extension GMSMapView {
    
    func showMarker(type:MarkerType,
                            location:CLLocationCoordinate2D,
                            iconName:String? = nil,
                            text:String? = nil,
                            name:String? = nil,
                            snippet:String? = nil) {
        let marker = GMSMarker(position: location)
        marker.title = name
        marker.snippet = snippet
        marker.map = self
        marker.zIndex = 1
        
        switch type {
        case .From:
            let labelOrder = labelMarkerWithText("FROM", .From)
            marker.iconView = labelOrder
            
        case .To:
            let labelOrder = labelMarkerWithText("TO",.To)
            marker.iconView = labelOrder
            
        case .Port:
            let portMarker = self.portMarker(E(iconName))
            marker.iconView = portMarker
            
        case .Normal:
            let portMarker = labelMarkerWithText(E(text),.Normal)
            marker.iconView = portMarker
        }
    }
    
    func drawPath(fromLocation from: CLLocationCoordinate2D,
                  toLocation to: CLLocationCoordinate2D,
                  wayPoints:Array<CLLocationCoordinate2D>,
                  complation:@escaping (Bool,[DirectionRoute]?) -> Void) {
        SERVICES().API.getDirection(origin: from,
                           destination: to,
                           waypoints: wayPoints) {[weak self] (result) in
                            switch result{
                            case .object(let obj):
                                for route in obj.routes {
                                    self?.drawPath(directionRoute: route)
                                }
                                complation(true,obj.routes)
                            case .error(let error):
                                //self?.showAlertView(error.getMessage())
                                complation(false,nil)
                                break
                            }
        }
    }
    
    func drawPath(directionRoute:DirectionRoute)  {
        let path = GMSPath(fromEncodedPath: directionRoute.polyline)
        let polyLine = GMSPolyline.init(path: path)
        polyLine.strokeWidth = Constants.ROUTE_WIDTH
        polyLine.strokeColor = AppColor.mainColor
        polyLine.map = self
        let bounds = GMSCoordinateBounds(path: path!)
        self.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
    }
    
    
    // MARK: - Private funtion
    private func labelMarkerWithText(_ text:String,_ type:MarkerType) -> UILabel {
        let labelOrder = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        labelOrder.text = text
        labelOrder.textAlignment = .center
        labelOrder.textColor = .white
        labelOrder.clipsToBounds = true
        labelOrder.cornerRadius = labelOrder.frame.width / 2

        switch type {
        case .From:
            labelOrder.backgroundColor = AppColor.orangeColor
            labelOrder.frame = CGRectMake(0, 0, 60, 30)
            labelOrder.cornerRadius = 4

        case .To:
            labelOrder.backgroundColor = AppColor.mainColor
            labelOrder.frame = CGRectMake(0, 0, 60, 30)
            labelOrder.cornerRadius = 4

        default:
            break
        }
        return labelOrder
    }
    
    private func portMarker(_ iconName:String) -> UIImageView {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        image.image = UIImage(named: iconName)
        image.contentMode = .scaleAspectFit
        return image
    }
}
