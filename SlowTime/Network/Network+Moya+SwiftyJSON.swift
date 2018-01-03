//
//  Network+Moya+SwiftyJSON.swift
//  hexa
//
//  Created by KKING on 2017/1/12.
//  Copyright © 2017年 vincross. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import Result
import SwiftyJSON
import PKHUD

public enum HexaError: Swift.Error {
    case statusCode(String, String)
    case dataIsEmpty
    case noNetwork
}

extension HexaError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .statusCode(let code, let msg):
            return "Status code: \(code)\n Error: \(msg)"
        case .noNetwork:
            return "No network"
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
            DLog("现在没网")
            closure(.failure(MoyaError.underlying(HexaError.noNetwork, nil)))
            return
        }
        
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

public typealias ErrorClosure = (String, String) -> Void

fileprivate extension JSON {
    
    fileprivate func filterSuccessfulCode(_ closure: ErrorClosure?) throws -> JSON {
        let code = self["code"].stringValue
        
        guard code == requestSuccessCode else {
            let message = self["message"].stringValue
            closure?(code, message)
            throw HexaError.statusCode(code, message)
        }
        return self
    }
    
    
    fileprivate func filterObject<T: Parseable>(to type: T.Type) -> T {
        return T(json: self["data"][T.identifier])
    }
    
    
    fileprivate func map<T: Parseable>(to type: T.Type) -> [T] {
        return self["data"][T.identifier].arrayValue
            .map { T(json: $0) }
    }
    
    fileprivate func flatMap<T: Parseable>(to type: T.Type) throws -> [T] {
        let arr = self["data"][T.identifier].arrayValue
        guard !arr.isEmpty else {
            throw HexaError.dataIsEmpty
        }
        return arr.map { T(json: $0) }
    }
}

public extension ObservableType where E == JSON {
    
    public func filterObject<T: Parseable>(to type: T.Type) -> Observable<T> {
        return flatMap { json -> Observable<T> in
            return Observable.just(json.filterObject(to: type))
        }
    }
    
    
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

// MARK: - requestWithLoading
public extension Reactive where Base: Moya.MoyaProviderType {
    
    public func requestWithLoading(_ token: Base.Target) -> Observable<Response> {
        return base.rxRequestWithLoading(token)
    }
}

internal extension MoyaProviderType {
    
    internal func rxRequestWithLoading(_ token: Target) -> Observable<Response> {
//        HUD.flash(.rotatingImage(RI.progress()))
        return Observable.create { observer in
            let cancellableToken = self.request(token, callbackQueue: nil, progress: nil) { result in
//                HUD.hide()
                switch result {
                case let .success(response):
                    observer.onNext(response)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                if !cancellableToken.isCancelled {
//                    HUD.hide()
                    cancellableToken.cancel()
                }
            }
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

public extension ObservableType where E == Moya.Response {
    
    public func mapJSON() -> Observable<JSON> {
        return debug()
            .do(onError: { (_) in
                DLog("请求超时")
            })
            .flatMap { (response) -> Observable<JSON> in
                return Observable.just(try response.mapToJSON())
        }
    }
    
}
