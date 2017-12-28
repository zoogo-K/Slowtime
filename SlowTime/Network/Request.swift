//
//  Request.swift
//  hexa
//
//  Created by KKING on 2017/1/12.
//  Copyright © 2017年 vincross. All rights reserved.
//

import Foundation
import Moya

extension Moya.TargetType {
    var rootDomain: String {
        #if DEBUG
            return "https://api.vincross.com"
        #else
            return "https://api.vincross.com"
        #endif
    }
    
    public var parameters: [String : Any]? { return nil }
    
    public var parameterEncoding: Moya.ParameterEncoding {
        return Moya.JSONEncoding.default
    }
    
    public var sampleData: Data { return "Test data".data(using: .utf8)! }
    
    public var task: Task { return .requestPlain }
}

public struct Request {
}

// MARK: - Extension Request
public extension Request {
    enum User {
        case emailStatus(String)
    }
    
    enum Robot {
        case list
        case active(with: String)
        case call(with: String)
        case change(ownerHash: String, password: String, sn: String)
    }
    
}


// MARK: - Request.User
extension Request.User: Moya.TargetType {
    public var headers: [String : String]? {
        return nil
    }
    
    public var baseURL: URL {
        return URL(string: "\(rootDomain)/user-service/v1")!
    }
    
    public var path: String {
        switch self {
        case .emailStatus(let email):
            return "/users/status?type=email&email=" + email
        }
    }
    
    public var method: Moya.Method {
        switch self {
            
        default:
            return .get
        }
    }
    
    public var parameters: [String : Any]? {
        switch self {

        default:
            return nil
        }
    }
    
    public var task: Moya.Task {
        switch self {
        
        default:
            return .requestPlain
        }
    }
}

// MARK: - Request.Robot
extension Request.Robot: Moya.TargetType {
    public var headers: [String : String]? {
        return nil
    }
    
    public var baseURL: URL {
        return URL(string: "\(rootDomain)/robot-service/v1")!
    }
    
    public var path: String {
        switch self {
        case .list:
            return "/users/me/robots?online=all"
        case .active(let token):
            return "/users/me/robots?robotToken=" + token
        case .call(let sn):
            return "/videoCallers?robotSN=" + sn
        case .change:
            return "/users/me?action=changeRobotOwnerApply"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .change:
            return .post
        default:
            return .get
        }
    }
    
    public var parameters: [String : Any]? {
        switch self {
        case .change(let ownerHash, let password, let sn):
            return ["sn": sn, "newOwnerUserhash": ownerHash, "password": password]
        default:
            return nil
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .change:
            return .requestParameters(parameters: parameters!, encoding: parameterEncoding)
        default:
            return .requestPlain
        }
    }
}


