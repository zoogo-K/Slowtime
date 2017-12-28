//
//  RegexHelper.swift
//  hexa
//
//  Created by KKING on 2016/9/20.
//  Copyright © 2016年 vincross. All rights reserved.
//

import UIKit

struct Pattern {
    static let email = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
    static let lowerUpperCase = "([a-z]+)([A-Z]+)"
    static let number = "\\d"
    static let hexaName = "^([a-zA-Z\u{4E00}-\u{9FA5}\\d]+)$"
    
    static let passwordLength = "^.{8,32}$"
    static let passwordSymbol = "\\W"
    static let passwordLower = "[a-z]"
    static let passwordUpper = "[A-Z]"
    
    static let emoji = "[\\U00010000-\\U0010FFFF]"
    
    //是否是一个可用ip地址
    static let aviIp = "^(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|[1-9])\\."+"(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\."+"(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\."+"(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)$"
}

struct RegexHelper {
    let regex: NSRegularExpression
    
    init(_ pattern: String) throws {
        try regex = NSRegularExpression(pattern: pattern, options: [])
    }
    
    func match(_ input: String) -> Bool {
        let matches = regex.matches(in: input, options: [], range: NSMakeRange(0, input.utf16.count))
        return !matches.isEmpty
    }
}

precedencegroup MatchPrecedence {
    associativity: none
    higherThan: DefaultPrecedence
}

infix operator =~: MatchPrecedence

func =~(lhs: String, rhs: String) -> Bool {
    do {
        return try RegexHelper(rhs).match(lhs)
    } catch {
        return false
    }
}
