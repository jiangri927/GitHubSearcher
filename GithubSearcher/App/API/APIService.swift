//
//  APIConstant.swift
//  ActionIWS
//
//  Created by Jiang on 26/07/2021.
//

import Foundation
import ObjectMapper
import Moya

enum APIService {
    
    ///Chapters
    case users(filter: String?)
    case getUser(username: String)
    
    case repositories(username:String)
}

extension APIService: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var path: String {
        switch self {
        case .users(let filter):
            if filter != nil {
                return "/search/users"
            } else {
                return "/users"
            }
        case .getUser(let username):
            return "/users/\(username)"
        case .repositories(let username):
            return "/users/\(username)/repos"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var params: [String: Any]? {
        switch self {
        case .users(let filter):
            if let filter = filter {
                return ["q": filter]
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    var task: Task {
        if let params = self.params {
            if self.method == .get {
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
            }
            else {
                return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            }
        }
        else {
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var showHud: Bool {
        return true
    }
}

extension APIService: AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .none
    }
}

struct ServerResponse: Mappable {
    var success: Bool!
    var message: String!
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        success <- map["success"]
        message <- map["message"]
    }
}

private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
