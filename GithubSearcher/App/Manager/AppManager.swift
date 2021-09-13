//
//  AppManager.swift
//  GithubSearcher
//
//  Created by Jiang on 27/07/2021.
//


import UIKit

class AppManager: NSObject {
    static let shared = AppManager()
    
}

///App Flow
extension AppManager {
    func showNext() {
        UIManager.showMain(animated: true)
    }
}
