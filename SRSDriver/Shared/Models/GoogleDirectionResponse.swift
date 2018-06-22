//
//  GoogleDirectionResponse.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 3/27/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import Foundation
import ObjectMapper
import MapKit

class DirectionStep: NSObject, Mappable {
  var distance = Object()
  var duration = Object()
  var travelMode = ""
  var endLocation = GoogleCoordinate()
  var startLocation = GoogleCoordinate()
  var instructions = ""
  var polyline = ""
  var maneuver = ""
  
  convenience required init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    distance <- map["distance"]
    duration <- map["duration"]
    endLocation <- map["end_location"]
    startLocation <- map["start_location"]
    travelMode <- map["travel_mode"]
    instructions <- map["html_instructions"]
    polyline <- map["polyline.points"]
    maneuver <- map["maneuver"]
  }
  
  
}

class Object: NSObject, Mappable {
  var text: String = ""
  var value: Int = 0
  
  convenience required init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    text <- map["text"]
    value <- map["map"]
  }
}

class DirectionLeg: NSObject, Mappable {
  var distance = Object()
  var duration = Object()
  var endAddress = ""
  var startAddress = ""
  var steps = [DirectionStep]()
  
  convenience required init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    distance <- map["distance"]
    duration <- map["duration"]
    endAddress <- map["end_address"]
    startAddress <- map["start_address"]
    steps <- map["steps"]
  }
  
}

class GoogleCoordinate: NSObject, Mappable {
  var lat: Double = 0.0
  var lng: Double = 0.0
  
  convenience required init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    lat <- map["lat"]
    lng <- map["lng"]
  }
  
  func toCoordinate() -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: lat, longitude: lng)
  }
  
}

class DirectionRoute: NSObject, Mappable {
  var polyline: String = ""
  var boundsNortheast = GoogleCoordinate()
  var boundsSouthest = GoogleCoordinate()
  var legs = [DirectionLeg]()
  
  
  convenience required init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    polyline <- map["overview_polyline.points"]
    boundsSouthest <- map["bounds.southwest"]
    boundsNortheast <- map["bounds.northeast"]
    legs <- map["legs"]
  }
}

class MapDirectionResponse: NSObject, Mappable {
  var routes: [DirectionRoute] = [DirectionRoute]()
  var status = ""
  convenience required init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    routes <- map["routes"]
    status <- map["status"]
  }
  
  
}
