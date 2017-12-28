//
//  Array+hexa.swift
//  hexa
//
//  Created by KKING on 2016/11/25.
//  Copyright © 2016年 vincross. All rights reserved.
//

import Foundation

public extension Array where Element: Equatable {
    @discardableResult
    public mutating func remove(_ element: Element) -> Element? {
        return remove(where: { $0 == element })
    }
}

public extension Array {
    public subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    public func object(where predicate: (Element) -> Bool) -> Element? {
        if let index = index(where: predicate) {
            return self[index]
        }else {
            return nil
        }
    }
    
    public func count(where predicate: (Element) -> Bool) -> Int {
        return filter(predicate).count
    }
    
    @discardableResult
    public mutating func remove(where predicate: (Element) -> Bool) -> Element? {
        if let index = index(where: predicate) {
            return remove(at: index)
        }else {
            return nil
        }
    }
    
    public mutating func moveToLast(where predicate: (Element) -> Bool) -> Bool {
        if let index = index(where: predicate) {
            append(remove(at: index))
            return true
        }else {
            return false
        }
    }
    
    public var isEmpty: Bool {
        return count == 0
    }
}
