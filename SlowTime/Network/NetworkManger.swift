//
//  NetworkManger.swift
//  hexa
//
//  Created by KKING on 16/8/4.
//  Copyright © 2016年 vincross. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

public typealias DownloadProgress = Alamofire.Request.ProgressHandler


public enum NetworkReachabilityStatus {
    case wwan, wifi, notReachable, unknown
}

public class NetworkReachability {
    
    static let shared = NetworkReachability()
    
    let reachabilityVariable = Variable(NetworkReachabilityStatus.unknown)
    
    var isReachable: Bool {
        return reachability?.isReachable ?? false
    }
    
    var isReachableOnWifi: Bool {
        return reachability?.isReachableOnEthernetOrWiFi ?? false
    }
    
    let reachability: Alamofire.NetworkReachabilityManager? = {
        $0?.listener = { status in
            NetworkReachability.shared.statusChanged(status)
        }
        $0?.startListening()
        return $0
    }(NetworkReachabilityManager(host: "www.apple.com"))
    
    private func statusChanged(_ status: Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus) {
        switch status {
        case .unknown:
            reachabilityVariable.value = .unknown
        case .notReachable:
            reachabilityVariable.value = .notReachable
        case .reachable(let type):
            switch type {
            case .wwan:
                reachabilityVariable.value = .wwan
            case .ethernetOrWiFi:
                reachabilityVariable.value = .wifi
            }
        }
    }
}

final class NetworkManger {
    
    static let shared = NetworkManger()
    
    public let sessionManager: Alamofire.SessionManager = {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
//        configuration.timeoutIntervalForResource = 10
        let acceptLanguage = Locale.preferredLanguages
            .prefix(6)
            .enumerated()
            .map { index, languageCode in
                let quality = 1.0 - (Double(index) * 0.1)
                return "\(languageCode),q=\(quality)"
            }
            .joined(separator: ", ")
        
        let userAgent: String = {
            if let info = Bundle.main.infoDictionary {
                return "HEXA/iOS/" + (info["CFBundleShortVersionString"] as? String ?? "Unknown")
            }
            return "HEXA/iOS/Unknown"
        }()
        configuration.httpAdditionalHeaders = ["Accept-Encoding": "gzip;q=1.0, compress;q=0.5", "Accept-Language": acceptLanguage, "User-Agent": userAgent]
        var manager: Alamofire.SessionManager
        #if DEBUG
            manager = Alamofire.SessionManager(configuration: configuration)
        #else
//            manager = Alamofire.SessionManager(configuration: configuration)
            let serverTrustPolicies: [String: ServerTrustPolicy] = [
                "api.vincross.com": .performDefaultEvaluation(validateHost: true)
            ]
            manager = Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: Alamofire.ServerTrustPolicyManager(policies: serverTrustPolicies))
        #endif
        manager.startRequestsImmediately = false
        return manager
    }()
    
    var accessToken: Alamofire.HTTPHeaders {
        var headers = Alamofire.HTTPHeaders()
        headers["X-App-OSVersion"] = UIDevice.systemVersionName
        headers["X-App-Device"] = UIDevice.machineModelName

        
        return headers
    }
    

    
}
