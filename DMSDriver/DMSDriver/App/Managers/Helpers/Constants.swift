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
  static let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
  static let toolbarHeight: CGFloat = 44.0
  static let pickerViewHeight: CGFloat = 216.0
  static let maxSizeForImageUploading = 500000
  static let messageTabIndex: Int = 3
  static let packageTabIndex: Int = 1

  static let refreshTimeInterval: Double = 15

  static let NAVIGATION_BAR_HEIGHT: CGFloat = 64.0
  static let SCALE_VALUE_HEIGHT_DEVICE = (DeviceType.IS_IPAD ? 1.2 : (DeviceType.IS_IPHONE_6 ? 1.0 : (DeviceType.IS_IPHONE_6P ? 1.174 : 1.0))) as CGFloat
  
  static let SCALE_VALUE_WIDTH_DEVICE  = (DeviceType.IS_IPAD ? 1.2 : (DeviceType.IS_IPHONE_6 ? 1.0 : (DeviceType.IS_IPHONE_6P ? 1.171 : 0.9))) as CGFloat
  
  static let FONT_SCALE_VALUE          = (DeviceType.IS_IPAD ? 1.2 : (DeviceType.IS_IPHONE_6P ? 1.1 : (DeviceType.IS_IPHONE_6 ? 1.00 : 0.9))) as CGFloat
  
  static let RATIO_WIDTH               = (DeviceType.IS_IPHONE_6 ? 1.0 : ScreenSize.SCREEN_WIDTH / 375)
  
  static let RATIO_HEIGHT              = (DeviceType.IS_IPHONE_6 ? 1.0 : ScreenSize.SCREEN_HEIGHT / 667)
  
  static let REQUEST_LOCATION_INTERVAL: Double = 60.0
  static let ROUTE_WIDTH: CGFloat              = 4.0
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

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
}


struct Defaultkey {
    static let tokenKey = "token"
    static let fcmToken = "fcmToken"
    static let firstLaunch = "firstLaunch"
    static let userStatus = "userStatus"
    static let keepLogin = "keepLogin"
    static let SF_USER = "SF_USER"
    static let SF_REMEBER_LOGIN = "SF_REMEBER_LOGIN"
    static let SF_DRIVING_RULE = "SF_DRIVING_RULE"
    static let SF_SAVE_DATE_START_ROUTE = "SF_SAVE_DATE_START_ROUTE"
    static let SF_SAVE_LOCATION = "SF_SAVE_LOCATION"
    static let SF_PAUSE_DATE_ROUTE = "SF_PAUSE_DATE_ROUTE"


    // TimerVC
    static let starting = "starting"
    static let pause = "pausepause"
    static let cancel = "cancel"
    static let timeRemaining = "timeRemaining"
    static let timePlaying = "timePlaying"

}

struct NotificationName {
    static let shouldUpdateMessageNumbers = "shouldUpdateMessageNumbers"
    static let remiderTimeoutDrivingRole =  "remider.timeout.drivingrole"
}


struct SegueIdentifier {
  static let showHome = "showHomeSegue"
  static let showOrderDetail = "orderDetailSegue"
  static let showMapView = "showMapView"
  static let showReasonList = "showReasonList"
  static let showScanBarCode = "showScanBarCode"
}

//SBName
public enum SBName : String {
    case Main = "Main";
    case Route = "Route";
    case Login = "Login";
    case Order = "Order";
    case Packages = "Packages";
    case Map = "Map";
    case Task = "Task";
    case Profile = "Profile";
    case Common = "Common";
    case Dashboard = "Dashboard";
    case Notification = "Notification";

}

func MAX<T>(_ x: T, _ y: T) -> T where T : Comparable {
    return x > y ? x : y
}

func MIN<T>(_ x: T, _ y: T) -> T where T : Comparable {
    return x < y ? x : y
}

func ABS<T>(_ x: T) -> T where T : Comparable, T : SignedNumeric {
    return x < 0 ? -x : x
}

func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRect(x: x, y: y, width: width, height: height)
}

func isHebewLang() -> Bool {
    return Locale.current.languageCode == "he"
}

func isEmpty(_ val: String?) -> Bool {
    return val == nil ? true : val!.isEmpty;
}

func ClassName(_ object: Any) -> String {
    return String(describing: type(of: object))
}

func App() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate;
}

func Caches() -> Cache {
    return Cache.shared
}


