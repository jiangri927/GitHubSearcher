//
//  User.swift
//  GithubSearcher
//
//  Created by Jiang on 27/07/2021.
//

import UIKit
import ObjectMapper
import RxSwift
import SwiftyJSON

class User: BaseObject {
    var avatar_url      : URL?
    var name            : String?
    var username        : String?
    var public_repos    : Int?
    var email           : String?
    var location        : String?
    var followers       : Int?
    var following       : Int?
    var bio             : String?
    
    /* Full information of github user
     
    var login:String?
    var node_id : String?
    var avatar_url : URL?
    var gravatar_id : String?
    var url: URL?
    var html_url : URL?
    var followers_url : URL?
    var following_url : URL?
    var gists_url : URL?
    var starred_url : URL?
    var subscriptions_url:URL?
    var organizations_url:URL?
    var repos_url:URL?
    var events_url:URL?
    var received_events_url:URL?
    var type:String?
    var site_admin:Bool?
    var name:String?
    var company:String?
    var blog:URL?
    var location:String?
    var email:String?
    var hireable:Bool?
    var bio:String?
    var twitter_username:String?
    var public_repos:Int?
    var public_gists:Int?
    var followers:Int?
    var following:Int?
    var private_gists:Int?
    var total_private_repos:Int?
    var owned_private_repos:Int?
    var disk_usage:Int?
    var collaborators:Int?
    var two_factor_authentication:Bool?
    var plan:Plan?*/
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        name                    <- map["name"]
        username                <- map["login"]
        public_repos            <- (map["public_repos"], IntTransform.shared)
        avatar_url              <- (map["avatar_url"], URLTransform.shared)
        email                   <- map["email"]
        location                <- map["location"]
        followers               <- (map["followers"], IntTransform.shared)
        following               <- (map["following"], IntTransform.shared)
        bio                     <- map["bio"]
    }
    
}

extension User {
    static func get(_ filter:String?) -> Single<[User]> {
       return Self.provider.request(.users(filter:filter)).filterResponse().mapArray(User.self)
    }
    
    
    static func getDetails(_ username:String) -> Single<User> {
       return Self.provider.request(.getUser(username: username)).filterResponse().mapObject(User.self)
    }
}
