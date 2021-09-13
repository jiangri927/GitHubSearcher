//
//  APIMock.swift
//  GithubSearcher
//
//  Created by Jiang on 26/07/2021.
//

import Foundation
import RxSwift

class APIMock {
    static let shared = APIMock()
}

extension APIMock {
    func getUsers() -> Observable<[User]> {
        return Observable.create { observer in
            observer.onNext([])
            observer.onCompleted()
            return Disposables.create()
        }
    }
    func getRepositories() -> Observable<[Repository]> {
        return Observable.create { observer in
            observer.onNext([])
            observer.onCompleted()
            return Disposables.create()
        }
    }
}
