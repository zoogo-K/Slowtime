//
//  Request.swift
//  hexa
//
//  Created by KKING on 2017/1/12.
//  Copyright © 2017年 vincross. All rights reserved.
//

import Foundation
import Moya
import RxMoya

extension Moya.TargetType {
    var rootDomain: String {
        return "http://slowtime.vcrxyz.com"
    }
    
    public var parameters: [String : Any]? { return nil }
    
    public var parameterEncoding: Moya.ParameterEncoding {
        return Moya.JSONEncoding.default
    }
    
    public var sampleData: Data { return "Test data".data(using: .utf8)! }
    
    public var task: Task { return .requestPlain }
}

public enum Request {
    case loginCode(phone: String)
    case login(phoneNumber: String, loginCode: String)
    case logout
    case profile(nickName: String, profile: String)
    
    case friends
    case recommends
    
    case mailList(userhash: String)
    case deleteMail(mailId: String)
    case getMail(mailId: String)
    case writeMail(toUser: String, content: String)
    case editMail(mailId: String, toUser: String, content: String)
    case sendMail(stampId: String, mailId: String)
    
    case stamps
    case userStamp
    case orderStamp(stamps: [[String:String]])
}


// MARK: - Request.User
extension Request: Moya.TargetType {
    
    public var path: String {
        switch self {
        case .loginCode:
            return "/user/loginCode"
        case .login:
            return "/user/login"
        case .logout:
            return "/user/logout"
        case .profile:
            return "/user/profile"
        
        case .friends:
            return "/feed/friends"
        case .recommends:
            return "/feed/recommends"
            
        case .mailList(let userhash):
            return "/mail/inbox/\(userhash)"
        case .deleteMail(let mailId):
            return "/mail/\(mailId)"
        case .getMail(let mailId):
            return "/mail/\(mailId)"
        case .writeMail:
            return "/mail"
        case .editMail(let mailId, _, _):
            return "/mail/\(mailId)"

        case .sendMail(_, let mailId):
            return "/mail/send/\(mailId)"
            
        case .stamps:
            return "/stamps"
        case .userStamp:
            return "/stamps/user"
        case .orderStamp:
            return "/order"

        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .loginCode, .login, .logout, .profile, .writeMail, .orderStamp:
            return .post
        case .deleteMail:
            return .delete
        case .editMail, .sendMail:
            return .patch
        default:
            return .get
        }
    }
    
    public var parameters: [String : Any]? {
        switch self {
        case .loginCode(let phone):
            return ["phoneNumber": phone]
        case .login(let phone, let loginCode):
            return ["phoneNumber": phone, "loginCode": loginCode]
        case .profile(let nickName, let profile):
            return ["nickName": nickName, "profile": profile]
        case .writeMail(let toUser, let content):
            return ["toUser": toUser, "content": content]
        case .editMail(_, let toUser, let content):
            return ["toUser": toUser, "content": content]
        case .sendMail(let stampId, _):
            return ["stampId": stampId]
        case .orderStamp(let stamps):
            return ["stamps": stamps]
        default:
            return nil
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .loginCode, .login, .profile, .writeMail, .editMail, .sendMail, .orderStamp:
            return .requestParameters(parameters: parameters!, encoding: parameterEncoding)
        default:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    public var baseURL: URL {
        return URL(string: "\(rootDomain)/api/v1")!
    }
}


