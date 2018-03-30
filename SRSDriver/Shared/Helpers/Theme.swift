//
//  Theme.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 3/28/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import Foundation
import UIKit

enum Theme: Int {
  case light, dark, graphical
  
  var mainColor: UIColor {
    switch self {
    case .light:
      return UIColor(red: 87.0/255.0, green: 188.0/255.0, blue: 95.0/255.0, alpha: 1.0)
    case .dark:
      return UIColor(red: 242.0/255.0, green: 101.0/255.0, blue: 34.0/255.0, alpha: 1.0)
    default:
      return UIColor(red: 10.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 1.0)
    }
  }
  
  var barStyle: UIBarStyle {
    switch self {
    case .light, .graphical:
      return .default
    case .dark:
      return .black
    }
  }
  
  var navigationBackgroundImage: UIImage? {
    return self == .graphical ? UIImage(named: "barcode-scan") : nil
  }
  
}

struct ThemeManager {
  static func currentTheme() -> Theme {
    if let theme = UserDefaults.standard.value(forKey: "selectedThemeKey") as? Int {
      return Theme(rawValue: theme)!
    }
    return .light
  }
  
  static func applyTheme(_ theme: Theme) {
    UserDefaults.standard.setValue(theme.rawValue, forKey: "selectedThemeKey")
    UserDefaults.standard.synchronize()
    
    UIApplication.shared.delegate?.window??.tintColor = theme.mainColor
    UINavigationBar.appearance().barStyle = theme.barStyle
    UINavigationBar().barTintColor = theme.mainColor
    UINavigationBar().isTranslucent = false
//    UINavigationBar.appearance().transli
    UINavigationBar.appearance().setBackgroundImage(theme.navigationBackgroundImage, for: .default)
    
  }
  
  
}
