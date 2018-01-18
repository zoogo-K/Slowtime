//
//  URL+slowTime.swift
//  SlowTime
//
//  Created by KKING on 2018/1/18.
//  Copyright © 2018年 KKING. All rights reserved.
//

import Foundation

extension URL {
    public static var cacheURL: URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    public static var UserCacheURL: URL? {
        let fileManager = FileManager.default
        let UCacheURL = cacheURL.appendingPathComponent("com.cqm.user", isDirectory: true)
        do {
            try fileManager.createDirectory(at: UCacheURL, withIntermediateDirectories: true, attributes: nil)
            return UCacheURL
        } catch {
            DLog("Directory create: \(error)")
            return nil
        }
    }
    
    public static var CQMCacheURL: URL? {
        let subPath = "cqm.data"
        return URL.UserCacheURL?.appendingPathComponent(subPath, isDirectory: false)
    }
}
