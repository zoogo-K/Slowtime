//
//  Config.swift
//  Rota
//
//  Created by KKING on 16/8/22.
//  Copyright © 2016年 vincross. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// R.image
typealias RI = R.image
/// R.nib
typealias RN = R.nib
/// R.font
typealias RF = R.font


public func DLog<T>(_ message: T, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
    #if DEBUG
        let str: String = (fileName as NSString).pathComponents.last!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        print(formatter.string(from: Date()),"[\(str):\(lineNumber)] \(methodName) ->", message)
    #elseif ADHOC
        let str: String = (fileName as NSString).pathComponents.last!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        ScreenLog.shared.log(with: "\(formatter.string(from: Date())) [\(str):\(lineNumber)] \(methodName) -> \(message)")
    #endif
}

//全局Notification.Name
extension Notification.Name {
    static let DismissAndStop = Notification.Name("DismissAndStop")
    static let DismissAndDisconnect = Notification.Name("DismissAndDisconnect")

    
}


typealias Screen = Config.MainScreen

public struct Config {
    
    
    
    public struct MainScreen {
        public static var width: CGFloat {
            return min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        }
        public static var height: CGFloat {
            return max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        }
    }
    
    
    // 本地缓存的从前慢
    public static var CqmUser: Friend? {
        return Friend.create(with: NSDictionary(contentsOf: URL.CQMCacheURL!) ?? NSDictionary())
    }
    
    
    public static var randomColor: UIColor {
        //  产生随机的色值
        let red = arc4random() % 256
        let green = arc4random() % 256
        let blue = arc4random() % 256
        return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }
}

