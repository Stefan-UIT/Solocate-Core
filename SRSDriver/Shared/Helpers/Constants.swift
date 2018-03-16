//
//  Constants.swift
//  truck4less_dev
//
//  Created by phunguyen on 12/14/17.
//  Copyright © 2017 SeldatInc. All rights reserved.
//

import Foundation
import UIKit

/// Network constants
struct Network {
  static let googleAPIKey = "AIzaSyDXCigMmInLjLSiEoXRIBaS3teaFHiwtqs"
  static let registerAccountURL      = "https://t4l.seldatdirect.com/#/home"
  
  static let success: Int = 200
  static let unauthorized: Int = 401
  static let loginOtherPlace: Int = 406
}

/// Constants
struct Constants {
  static let toolbarHeight: CGFloat = 44.0
  static let pickerViewHeight: CGFloat = 216.0
  static let maxSizeForImageUploading = 500000

  static let refreshTimeInterval: Double = 15

  static let NAVIGATION_BAR_HEIGHT: CGFloat = 64.0
  static let SCALE_VALUE_HEIGHT_DEVICE = (DeviceType.IS_IPAD ? 1.2 : (DeviceType.IS_IPHONE_6 ? 1.0 : (DeviceType.IS_IPHONE_6P ? 1.174 : 1.0))) as CGFloat
  
  static let SCALE_VALUE_WIDTH_DEVICE  = (DeviceType.IS_IPAD ? 1.2 : (DeviceType.IS_IPHONE_6 ? 1.0 : (DeviceType.IS_IPHONE_6P ? 1.171 : 1.0))) as CGFloat
  
  static let FONT_SCALE_VALUE          = (DeviceType.IS_IPAD ? 1.2 : (DeviceType.IS_IPHONE_6P ? 1.1 : (DeviceType.IS_IPHONE_6 ? 1.00 : 0.9))) as CGFloat
  
  static let RATIO_WIDTH               = (DeviceType.IS_IPHONE_6 ? 1.0 : ScreenSize.SCREEN_WIDTH / 375)
  
  static let RATIO_HEIGHT              = (DeviceType.IS_IPHONE_6 ? 1.0 : ScreenSize.SCREEN_HEIGHT / 667)
  
  static let REQUEST_LOCATION_INTERVAL: Double = 60.0
  static let ROUTE_WIDTH: CGFloat              = 3.0
  static let MENU_CELL_HEIGHT: CGFloat              = 45.0 * (DeviceType.IS_IPAD ? 1.2 : (DeviceType.IS_IPHONE_6 ? 1.174 : (DeviceType.IS_IPHONE_6P ? 1.295 : 1.0))) as CGFloat
  static let ORDER_CELL_HEIGHT: CGFloat              = 150.0 * (DeviceType.IS_IPAD ? 1.2 : (DeviceType.IS_IPHONE_6 ? 1.174 : (DeviceType.IS_IPHONE_6P ? 1.295 : 1.0))) as CGFloat
}

// Window size
struct ScreenSize {
  static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
  static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
  static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
  static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

// Device type
struct DeviceType {
  static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
  static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
  static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
  static let IS_IPHONE_6_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH <= 667.0
  static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
  static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
  static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}

struct AppColor {
  static let mainColor            = UIColor(hex: "#037AFF")
}


struct Defaultkey {
  static let tokenKey = "token"
  static let fcmToken = "fcmToken"
  static let firstLaunch = "firstLaunch"
  static let userStatus = "userStatus"
}

struct NotificationName {
  static let shouldUpdateMessageNumbers = "shouldUpdateMessageNumbers"  
}


struct SegueIdentifier {
  static let orderDetail = "orderDetailSegue"
  static let showHome = "showHomeSegue"
  static let showOrderDetail = "orderDetailSegue"
  static let showMapView = "showMapView"
}

