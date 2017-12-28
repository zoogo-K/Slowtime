//
//  DispatchQueue+hexa.swift
//  hexa
//
//  Created by KKING on 2016/11/28.
//  Copyright © 2016年 vincross. All rights reserved.
//

import Foundation

extension DispatchQueue {
    
    //一般在global时使用
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
    
    static func mainAsync(_ block: @escaping ()->()) {
        DispatchQueue.main.safeAsync(block)
    }
    
    private static var _onceTracker = [String]()
    
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
    
}
