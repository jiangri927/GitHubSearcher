//
//  BaseObject.swift
//  GithubSearcher
//
//  Created by Jiang on 26/07/2021.
//

import UIKit
import ObjectMapper
import RxSwift
import Moya
import Moya_ObjectMapper

typealias SorterFunction = ((BaseObject, BaseObject) -> Bool)

class BaseObject: NSObject, Mappable {
    var id: Int?
    var createdAt: Date?
    var updatedAt: Date?
    
    static let sorterOldest: SorterFunction = { obj1, obj2 in
        guard let value1 = obj1.date, let value2 = obj2.date else {
            return (obj1.id ?? 0) < (obj2.id ?? 0)
        }
        return value1 < value2
    }
    
    static let sorterNewest: SorterFunction = { obj1, obj2 in
        guard let value1 = obj1.date, let value2 = obj2.date else {
            return (obj1.id ?? 0) > (obj2.id ?? 0)
        }
        return value1 > value2
    }
    
    static let sorterByAscending: SorterFunction = { obj1, obj2 in
        guard let value1 = obj1.id, let value2 = obj2.id else {
            return false
        }
        return value1 < value2
    }
    
    static let sorterByDescending: SorterFunction = { obj1, obj2 in
        guard let value1 = obj1.id, let value2 = obj2.id else {
            return false
        }
        return value1 < value2
    }


    var stringId: String {
        guard let id = id else {
            return ""
        }
        return "\(id)"
    }
    
    var date: Date? {
        return self.updatedAt ?? self.createdAt
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id                  <- (map["id"], IntTransform.shared)
        createdAt           <- (map["created_at"], DateFormatTransform.shared)
        updatedAt           <- (map["updated_at"], DateFormatTransform.shared)
    }
    
    static func map<T: Mappable>(json: Any) -> T? {
        let mapper = Mapper<T>()
        return mapper.map(JSONObject: json)
    }
    
    func attach(_ model: BaseObject) {
        id = model.id ?? id
        createdAt = model.createdAt ?? createdAt
        updatedAt = model.updatedAt ?? updatedAt
    }
}

//API
extension BaseObject {
    class var provider: APIProvider<APIService> {
        return API.shared.provider
    }
}


extension BaseObject {
    static func == (lhs: BaseObject, rhs: BaseObject) -> Bool {
        guard let lid = lhs.id, let rid = rhs.id else {
            return false
        }
        return lid == rid
    }
}
