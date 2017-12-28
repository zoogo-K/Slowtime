//
//  UIDevice+hexa.swift
//  hexa
//
//  Created by KKING on 2017/3/14.
//  Copyright © 2017年 vincross. All rights reserved.
//

import UIKit

extension UIDevice {
    static var systemVersionName: String {
        return UIDevice.current.systemName + UIDevice.current.systemVersion
    }
    
    static var machineModelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children
            .reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "Watch1,1":    return "Apple Watch 38mm"
        case "Watch1,2":    return "Apple Watch 42mm"
        case "Watch2,3":    return "Apple Watch Series 2 38mm"
        case "Watch2,4":    return "Apple Watch Series 2 42mm"
        case "Watch2,6":    return "Apple Watch Series 1 38mm"
        case "Watch1,7":    return "Apple Watch Series 1 42mm"
        case "iPod1,1":     return "iPod touch 1"
        case "iPod2,1":     return "iPod touch 2"
        case "iPod3,1":     return "iPod touch 3"
        case "iPod4,1":     return "iPod touch 4"
        case "iPod5,1":     return "iPod touch 5"
        case "iPod7,1":     return "iPod touch 6"
        case "iPhone1,1":   return "iPhone 1G"
        case "iPhone1,2":   return "iPhone 3G"
        case "iPhone2,1":   return "iPhone 3GS"
        case "iPhone3,1":   return "iPhone 4 (GSM)"
        case "iPhone3,2":   return "iPhone 4"
        case "iPhone3,3":   return "iPhone 4 (CDMA)"
        case "iPhone4,1":   return "iPhone 4S"
        case "iPhone5,1":   return "iPhone 5"
        case "iPhone5,2":   return "iPhone 5"
        case "iPhone5,3":   return "iPhone 5c"
        case "iPhone5,4":   return "iPhone 5c"
        case "iPhone6,1":   return "iPhone 5s"
        case "iPhone6,2":   return "iPhone 5s"
        case "iPhone7,1":   return "iPhone 6 Plus"
        case "iPhone7,2":   return "iPhone 6"
        case "iPhone8,1":   return "iPhone 6s"
        case "iPhone8,2":   return "iPhone 6s Plus"
        case "iPhone8,4":   return "iPhone SE"
        case "iPhone9,1":   return "iPhone 7"
        case "iPhone9,2":   return "iPhone 7 Plus"
        case "iPhone9,3":   return "iPhone 7"
        case "iPhone9,4":   return "iPhone 7 Plus"
        case "iPad1,1":     return "iPad 1"
        case "iPad2,1":     return "iPad 2 (WiFi)"
        case "iPad2,2":     return "iPad 2 (GSM)"
        case "iPad2,3":     return "iPad 2 (CDMA)"
        case "iPad2,4":     return "iPad 2"
        case "iPad2,5":     return "iPad mini 1"
        case "iPad2,6":     return "iPad mini 1"
        case "iPad2,7":     return "iPad mini 1"
        case "iPad3,1":     return "iPad 3 (WiFi)"
        case "iPad3,2":     return "iPad 3 (4G)"
        case "iPad3,3":     return "iPad 3 (4G)"
        case "iPad3,4":     return "iPad 4"
        case "iPad3,5":     return "iPad 4"
        case "iPad3,6":     return "iPad 4"
        case "iPad4,1":     return "iPad Air"
        case "iPad4,2":     return "iPad Air"
        case "iPad4,3":     return "iPad Air"
        case "iPad4,4":     return "iPad mini 2"
        case "iPad4,5":     return "iPad mini 2"
        case "iPad4,6":     return "iPad mini 2"
        case "iPad4,7":     return "iPad mini 3"
        case "iPad4,8":     return "iPad mini 3"
        case "iPad4,9":     return "iPad mini 3"
        case "iPad5,1":     return "iPad mini 4"
        case "iPad5,2":     return "iPad mini 4"
        case "iPad5,3":     return "iPad Air 2"
        case "iPad5,4":     return "iPad Air 2"
        case "iPad6,3":     return "iPad Pro (9.7 inch)"
        case "iPad6,4":     return "iPad Pro (9.7 inch)"
        case "iPad6,7":     return "iPad Pro (12.9 inch)"
        case "iPad6,8":     return "iPad Pro (12.9 inch)"
        case "AppleTV2,1":  return "Apple TV 2"
        case "AppleTV3,1":  return "Apple TV 3"
        case "AppleTV3,2":  return "Apple TV 3"
        case "AppleTV5,3":  return "Apple TV 4"
        case "i386":        return "Simulator x86"
        case "x86_64":      return "Simulator x64"
        default:            return identifier
        }
    }
}
