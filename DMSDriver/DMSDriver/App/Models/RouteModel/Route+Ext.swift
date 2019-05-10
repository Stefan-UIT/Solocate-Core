//
//  Route+Ext.swift
//  DMSDriver
//
//  Created by Seldat on 5/10/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import GoogleMaps

//MARK: - Helper method
extension Route {
    func checkInprogess() -> Bool {
        var result = false
        for item in orderList{
            if item.statusOrder == .inProcessStatus{
                result = true
                break
            }
        }
        
        return result
        
    }
    
    func checkFinished() -> Bool {
        var result = true
        for item in orderList{
            if item.statusOrder != .deliveryStatus{
                result = false
                break
            }
        }
        
        return result
    }
    
    func orders(_ _status:StatusOrder) -> [Order] {
        let arr = getOrderList().filter({ (order) -> Bool in
            return order.statusOrder == _status
        })
        return arr
    }
    
    func getOrderList() -> [Order] {
        orderList.forEach { (order) in //add driverId to order
            order.driver_id = driverId
        }
        return Array(orderList)
    }
    
    func updateStatusWhenOffline()  {
        if !ReachabilityManager.isNetworkAvailable {
            var hasNew = false
            var hasInprocessStatus = false
            var hasDV = false
            var hasCanceled = false
            
            orderList.forEach { (order) in
                
                if order.statusOrder == .newStatus{
                    hasNew = true
                }
                
                if order.statusOrder == .inProcessStatus{
                    hasInprocessStatus = true
                }
                
                if order.statusOrder == .deliveryStatus{
                    hasDV = true
                }
                
                if order.statusOrder == .cancelStatus{
                    hasCanceled = true
                }
            }
            
            if hasNew && (!hasInprocessStatus && !hasDV && !hasCanceled) {
                status?.code = "OP"
            }else if hasCanceled  && (!hasNew && !hasInprocessStatus && !hasDV){
                status?.code = "CC"
            }else if hasDV && (!hasNew && !hasInprocessStatus){
                status?.code = "DV"
            }else if (hasInprocessStatus || hasDV){
                status?.code = "IP"
            }
        }
    }
    
    func arrayOrderMarkersFromOrderList() -> [OrderMarker] {
        var  array = [OrderMarker]()
        for order in orderList {
            let orderMarker = OrderMarker.init(order)
            array.append(orderMarker)
        }
        return array
    }
    
    func distinctArrayOrderList() -> [Order] {
        //temp function
        var  addedArray = [Order]()
        for index in orderList {
            //            let array = addedArray.filter({$0.lat == index.lat && $0.lng == index.lng})
            //            if array.count > 0 {
            //                continue
            //            }
            addedArray.append(index)
        }
        
        return addedArray
    }
    
    func getListLocations() -> [Address] {
        return locationList
        /*
         var  array = [Address]()
         orderList.forEach { (order) in
         if let fromAddress = order.from {
         array.append(fromAddress)
         }
         if let toAddress = order.to{
         array.append(toAddress)
         }
         }
         return array
         */
    }
    
//    func groupingLocationList() -> [GroupLocatonModel] {
//        var result:[GroupLocatonModel] = []
//
//        return result
//    }
    
    func getChunkedListLocation() -> [[CLLocationCoordinate2D]] {
        let locationList = getListLocations()
        let sortedList = locationList.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.seq <= rhs.seq
        })
        let currentLocation = LocationManager.shared.currentLocation?.coordinate
        var listLocation:[CLLocationCoordinate2D] = (currentLocation != nil) ? [currentLocation!] : []
        
        for i in 0..<(sortedList.count) {
            let location = CLLocationCoordinate2D(latitude: sortedList[i].lattd?.doubleValue ?? 0,
                                                  longitude: sortedList[i].lngtd?.doubleValue ?? 0)
            listLocation.append(location)
        }
        
        var listChunked = listLocation.chunked(by: 22)
        if listChunked.count > 1 {
            for i in 1..<listChunked.count{
                if let first = listChunked[i].first {
                    listChunked[i - 1].append(first)
                }
            }
        }
        
        return listChunked
    }
}
