//
//  Network+Moya+SwiftyJSON.swift
//  hexa
//
//  Created by KKING on 2017/1/12.
//  Copyright © 2017年 vincross. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Result
import RxMoya
import UIKit
import SwiftyJSON

public enum HexaError: Swift.Error {
    case statusCode(String, String)
    case dataIsEmpty
    case noData
    case noNetwork
    case inDirectMode
}

extension HexaError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .statusCode(let code, let msg):
            return "Status code: \(code)\n Error: \(msg)"
        case .noData:
            return "No Data"
        case .noNetwork:
            return "No network"
        case .inDirectMode:
            return "Mobile is in the robot's wifi"
        case .dataIsEmpty:
            return "Data is empty"
        }
    }
}


public extension Moya.MoyaProvider {
    convenience init() {
        self.init(endpointClosure: MoyaProvider.endpointMapping, requestClosure: MoyaProvider.requestMapping, manager: NetworkManger.shared.sessionManager)
    }
    
    public final class func endpointMapping(for target: Target) -> Endpoint<Target> {
        let url = target.baseURL.absoluteString + target.path
        let endpoint = Endpoint<Target>(
            url: url,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            task: target.task,
            httpHeaderFields: NetworkManger.shared.accessToken
        )
        return endpoint
    }
    
    
    public final class func requestMapping(for endpoint: Endpoint<Target>, closure: RequestResultClosure) {
        guard NetworkReachability.shared.isReachable else {

            closure(.failure(MoyaError.underlying(HexaError.noNetwork, nil)))
            return
        }
        
//        if MindSDK.md_checkApMode() {
            //            HexaHUD.show(with: RLS.toast_YouAreInDL())不再弹出当前处于AP模式的toast
//            closure(.failure(MoyaError.underlying(HexaError.inDirectMode, nil)))
//            return
//        }
        
        do {
            let urlRequest = try endpoint.urlRequest()
            DLog(endpoint.debugDescription)
            closure(.success(urlRequest))
        } catch MoyaError.requestMapping(let url) {
            closure(.failure(MoyaError.requestMapping(url)))
        } catch MoyaError.parameterEncoding(let error) {
            closure(.failure(MoyaError.parameterEncoding(error)))
        } catch {
            closure(.failure(MoyaError.underlying(error, nil)))
        }
    }
}

extension Moya.Endpoint: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\n🌎🌎🌎\nRequest: \nURL: \(url)\nMethod: \(method)\nTask: \(task)\nHttpHeaderFields: \(String(describing: httpHeaderFields))\n🌎🌎🌎"
    }
}

private let requestSuccessCode = "OK"
private let tokenInvalidCode = "access_token_not_found"

public typealias ErrorClosure = (String, String) -> Void

fileprivate extension JSON {
    
    fileprivate func filterSuccessfulCode(_ closure: ErrorClosure?) throws -> JSON {
        let code = self["code"].stringValue
        
        guard code != tokenInvalidCode else {
//            (UIApplication.shared.delegate as? AppDelegate)?.needLogin()
            DispatchQueue.main.async {
//                if MindSDK.robot?.isConnected == true {
//                    MindSDK.robot?.md_disconnectRobot()
//                }
//                GlobalSkillManager.removeCache()
            }
            let message = self["message"].stringValue
            closure?(code, message)
            throw HexaError.statusCode(code, message)
        }
        
        guard code == requestSuccessCode else {
            let message = self["message"].stringValue
            closure?(code, message)
            throw HexaError.statusCode(code, message)
        }
        return self
    }
    
    fileprivate func map<T: Parseable>(to type: T.Type) -> [T] {
        if type is Country.Type {
            return self["data"]["config"][T.identifier].arrayValue
                .map { T(json: $0) }
        }
        return self["data"][T.identifier].arrayValue
            .map { T(json: $0) }
    }
    
    fileprivate func flatMap<T: Parseable>(to type: T.Type) throws -> [T] {
        var arr = self["data"][T.identifier].arrayValue
        if type is Country.Type {
            arr = self["data"]["config"][T.identifier].arrayValue
        }
        guard !arr.isEmpty else {
            throw HexaError.dataIsEmpty
        }
        return arr.map { T(json: $0) }
    }
}

public extension ObservableType where E == JSON {
    
    public func map<T: Parseable>(to type: T.Type) -> Observable<[T]> {
        return flatMap { json -> Observable<[T]> in
            return Observable.just(json.map(to: type))
        }
    }
    
    public func flatMap<T: Parseable>(to type: T.Type) -> Observable<[T]> {
        return flatMap { json -> Observable<[T]> in
            return Observable.just(try json.flatMap(to: type))
        }
    }
    
    public func filterSuccessfulCode(_ closure: ErrorClosure? = nil) -> Observable<JSON> {
        return flatMap { (result) -> Observable<JSON> in
            return Observable.just(try result.filterSuccessfulCode(closure))
        }
    }
}

fileprivate extension Moya.Response {
    
    fileprivate func mapToJSON() throws -> JSON {
        do {
            let json = try JSON(mapJSON())
            DLog("\n🐶🐶🐶\nData: \(json)\n🐶🐶🐶")
            return json
        } catch {
            throw Moya.MoyaError.jsonMapping(self)
        }
    }
    
}
