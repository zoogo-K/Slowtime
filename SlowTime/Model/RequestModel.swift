//
//  BaseModle.swift
//  hexa
//
//  Created by KKING on 16/8/5.
//  Copyright © 2016年 vincross. All rights reserved.
//

import UIKit
import SwiftyJSON

public struct User {
    public var id: Int?
    public var nickname: String?
    public var phoneNumber: String?
    public var userHash: String?
    public var profile: String?
    public var accessToken: String?
    public var createTime: String?
    public var updateTime: String?
    
    public init(id: Int? = 0, nickname: String? = nil, phoneNumber: String? = nil, userHash: String? = nil, profile: String? = nil, accessToken: String? = nil, createTime: String? = nil, updateTime: String? = nil) {
        self.id = id
        self.nickname = nickname
        self.phoneNumber = phoneNumber
        self.userHash = userHash
        self.profile = profile
        self.accessToken = accessToken
        self.createTime = createTime
        self.updateTime = updateTime
    }
}

extension User: Parseable {
    public static var identifier: String = "user"
    
    public init(json: JSON) {
        id          <-      json["id"].intValue
        nickname    <-      json["nickname"].stringValue
        phoneNumber <-      json["phoneNumber"].stringValue
        userHash    <-      json["userHash"].stringValue
        profile     <-      json["profile"].stringValue
        accessToken <-      json["accessToken"].stringValue
        createTime  <-      json["createTime"].stringValue
        updateTime  <-      json["updateTime"].stringValue
    }
}




public struct Friend {
    public var nickname: String?
    public var userHash: String?
    public var profile: String?
    public var hasNewMail: Bool?

    
    public init(nickname: String? = nil, userHash: String? = nil, profile: String? = nil, hasNewMail: Bool? = false) {
        self.nickname = nickname
        self.userHash = userHash
        self.profile = profile
        self.hasNewMail = hasNewMail
    }
}

extension Friend: Parseable {
    public static var identifier: String = "users"
    
    public init(json: JSON) {
        nickname    <-      json["nickname"].stringValue
        userHash    <-      json["userHash"].stringValue
        profile     <-      json["profile"].stringValue
        hasNewMail  <-      json["accessToken"].boolValue
    }
}



