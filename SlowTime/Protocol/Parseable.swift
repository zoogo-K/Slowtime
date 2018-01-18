//
//  Parseable.swift
//  hexa
//
//  Created by 郭源 on 16/9/6.
//  Copyright © 2016年 vincross. All rights reserved.
//

import UIKit
import SwiftyJSON

infix operator <-

public func <- <T>(left: inout T, right: T) {
    left = right
}

public func <- <T: Parseable>(left: inout T!, right: JSON) {
    left = T(json: right)
}

public func <- <T: Parseable>(left: inout [T]!, right: [JSON]) {
    left = right.flatMap { T(json: $0) }
}

public func <- <T: Parseable>(left: inout [T]!, right: String) {
    guard !right.isEmpty else { left = [T](); return }
    do {
        let json = try JSON(data: right.data(using: .utf8)!)
        left <- json.arrayValue
    } catch {
        print(error)
    }
}

public func <- <T: Parseable>(left: inout T!, right: String) {
    guard !right.isEmpty else { return }
    do {
        let json = try JSON(data: right.data(using: .utf8)!)
        left <- json
    } catch {
        print(error)
    }
}

// 增加一个初始化方法，以及一个identifier
public protocol Parseable {
    init(json: JSON)
    
    static var identifier: String { get }
}

// 归档
public protocol Archivable {
    var archived: NSDictionary { get }
}

