//
//  APIManager.swift
//  GithubSearcher
//
//  Created by Jiang on 26/07/2021.
//

import UIKit
import Alamofire
import ObjectMapper
import RxSwift
import Moya
import SwiftyJSON

enum AppError: Error {
    case unknown
    case networkConnection
    case invalidJSON
    case message(reason: String)
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "common_error".localized()
        case .networkConnection:
            return "network_connection_error".localized()
        case .invalidJSON:
            return "invalid_json_error".localized()
        case .message(let reason): return reason
        }
    }
}

class API {
    static let shared = API()
    var provider: APIProvider<APIService>!
    var showHudEnabled: Bool = true
    
    init() {
        let loadPlugin = NetworkActivityPlugin { [weak self] (type, target) in
            guard let weak_self = self, let target = target as? APIService else {
                return
            }
            
            switch type {
            case .began:
                if weak_self.showHudEnabled, target.showHud {
                    ProgressHUD.show()
                }
            case .ended:
                if weak_self.showHudEnabled, target.showHud {
                    ProgressHUD.dismiss()
                }
            }
        }
        
        let timeout = { (endpoint: Endpoint, closure: MoyaProvider.RequestResultClosure) -> Void in
            if var urlRequest = try? endpoint.urlRequest() {
                urlRequest.timeoutInterval = 20
                closure(.success(urlRequest))
            } else {
                closure(.failure(MoyaError.requestMapping(endpoint.url)))
            }
        }
        
        self.provider = APIProvider<APIService>(requestClosure: timeout, plugins: [loadPlugin])
    }
    
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    func filterSuccess() -> Single<Bool> {
        return flatMap { (response) -> Single<Bool> in
            return Single.just(true).subscribeOn(MainScheduler.instance)
        }
    }
    
    func filterResponse(filterData: Bool = true) -> Single<Element> {
        return flatMap { (response) -> Single<Element> in
            if filterData {
                let json = try? JSON(data: response.data)
                if let dict = json?.dictionary, let data = try? dict["items"]?.rawData() {
                    return Single.just(Response(statusCode: response.statusCode, data: data)).subscribeOn(MainScheduler.instance)
                } else {
                    return Single.just(Response(statusCode: response.statusCode, data: response.data)).subscribeOn(MainScheduler.instance)
                }
            }
            else {
                return Single.just(response).subscribeOn(MainScheduler.instance)
            }
        }
    }
}

