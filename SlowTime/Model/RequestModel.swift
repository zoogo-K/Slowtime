//
//  BaseModle.swift
//  hexa
//
//  Created by KKING on 16/8/5.
//  Copyright © 2016年 vincross. All rights reserved.
//

import UIKit
import SwiftyJSON

// MARK: - User
public enum Gender: String {
    case male, female, other, unSet
    
    public var description: String {
        switch self {
        case .male:
            return ""
        case .female:
            return ""
        case .other:
            return ""
        case .unSet:
            return ""
        }
    }
}

public struct User {
    public var email: String!
    public var userhash: String!
    public var firstName: String?
    public var lastName: String?
    public var gender: Gender?
    public var area: String?
    public var accessToken: String?
    public var lastConnectTime: String?
    public var refreshKey: String?
    public var avatar: String?
    public var status: Int!
    
    public init(email: String = "", userhash: String = "", firstName: String? = nil, lastName: String? = nil, gender: Gender? = .unSet, area: String? = nil, accessToken: String? = nil, lastConnectTime: String? = nil, refreshKey: String? = nil, avatar: String? = nil) {
        self.email = email
        self.userhash = userhash
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.area = area
        self.accessToken = accessToken
        self.lastConnectTime = lastConnectTime
        self.refreshKey = refreshKey
        self.avatar = avatar
    }
}


extension User: Parseable {
    public static var identifier: String = "users"
    
    public init(json: JSON) {
        email           <- json["email"].stringValue
        userhash        <- json["userhash"].stringValue
        firstName       <- json["firstName"].string
        lastName        <- json["lastName"].string
        gender          <- (Gender(rawValue: json["gender"].stringValue) ?? .unSet)
        area            <- json["area"].string
        accessToken     <- json["accessToken"].stringValue
        lastConnectTime <- json["lastConnectTime"].stringValue
        refreshKey      <- json["refreshKey"].string
        avatar          <- json["avatar"].string
        status          <- json["status"].intValue
    }
}



// MARK: - App Version
public struct Version: Parseable {
    public var device: String!
    public var version: String!
    public var versionSeq: Int!
    public var desc: String!
    public var downloadURL: String!
    public var status: Int!
    public var createTime: String!
    public var hasNewVersion: Bool!
    public var forceUpdate: Bool!
    
    public init(json: JSON) {
        device        <- json["device"].stringValue
        version       <- json["version"].stringValue
        versionSeq    <- json["versionSeq"].intValue
        desc          <- json["desc"].stringValue
        downloadURL   <- json["downloadURL"].stringValue
        status        <- json["status"].intValue
        createTime    <- json["createTime"].stringValue
        hasNewVersion <- json["hasNewVersion"].boolValue
        forceUpdate   <- json["forceUpdate"].boolValue
    }
    
    public static var identifier: String {
        return "versions"
    }
}

// MARK: - Country
public struct Country: Parseable {
    public static var identifier: String = "area"
    
    public var shortName: String!
    public var longName: String!
    public var subAreas: [Area]!
    
    public init(json: JSON) {
        shortName <- json["shortName"].stringValue
        longName  <- json["longName"].stringValue
        subAreas  <- json[Area.identifier].arrayValue
    }
}

public struct Area: Parseable {
    public static var identifier: String = "subAreas"
    
    public var shortName: String!
    public var longName: String!
    
    public init(json: JSON) {
        shortName <- json["shortName"].stringValue
        longName  <- json["longName"].stringValue
    }
}



