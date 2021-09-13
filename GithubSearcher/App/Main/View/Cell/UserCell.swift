//
//  UserCell.swift
//  GithubSearcher
//
//  Created by Jiang on 27/07/2021.
//

import UIKit
import RxCocoa
import RxDataSources
import RxSwift

class UserCell: BaseTableViewCell {
    
    // RxCocoa
    let disposeBag = DisposeBag()
    
    override class var identifier: String {
        return "user_cell"
    }
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var repoLbl: UILabel!
    
    func reset(_ user: User) {
        logoImageView.loadImage(url: user.avatar_url)
        
        if let username = user.username {
            nameLbl.text = username
            API.shared.showHudEnabled = false
            User.getDetails(username).observeOn(MainScheduler.asyncInstance).subscribe { user in
                API.shared.showHudEnabled = true
                self.repoLbl.text = "\(user.public_repos ?? 0)"
            } onError: { _ in
                API.shared.showHudEnabled = true
            }.disposed(by: disposeBag)
        }
        
        
    }
}
