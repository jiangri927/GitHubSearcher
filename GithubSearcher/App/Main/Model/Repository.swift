//
//  Repository.swift
//  GithubSearcher
//
//  Created by Jiang on 27/07/2021.
//

import UIKit
import ObjectMapper
import RxSwift
import SwiftyJSON

class Repository: BaseObject {
    
    var name: String?
    var full_name: String?
    var owner: User?
    var privateRep: Bool?
    var html_url: URL?
    var descriptionRep: String?
    var fork: Bool?
    var forks_count: Int?
    var stargazers_count: Int?
    var watchers_count: Int?

    override func mapping(map: Map) {
        super.mapping(map: map)
        name                        <- map["name"]
        full_name                   <- map["full_name"]
        owner                       <- map["owner"]
        privateRep                  <- (map["private"], BoolTransform.shared)
        html_url                    <- (map["html_url"], URLTransform.shared)
        descriptionRep              <- map["description"]
        fork                        <- (map["fork"], BoolTransform.shared)
        forks_count                 <- (map["forks_count"], IntTransform.shared)
        stargazers_count            <- (map["stargazers_count"], IntTransform.shared)
        watchers_count              <- (map["watchers_count"], IntTransform.shared)
    }
}

extension Repository {
    static func get(_ username:String) -> Single<[Repository]> {
       return Self.provider.request(.repositories(username:username)).filterResponse().mapArray(Repository.self)
    }
}
